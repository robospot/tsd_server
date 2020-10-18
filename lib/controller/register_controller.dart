import 'dart:async';

import 'package:aqueduct/aqueduct.dart';
import 'package:tsd/model/customer.dart';
import 'package:tsd/model/user.dart';
import 'package:tsd/utils/mailer.dart';

class RegisterController extends ResourceController {
  RegisterController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.post()
  Future<Response> createUser(@Bind.body(ignore: ['id']) User user,
      {@Bind.header('customerName') String customerName}) async {
    // Check for required parameters before we spend time hashing
    if (user.username == null || user.password == null) {
      return Response.badRequest(
          body: {"error": "username and password required."});
    }
    user
      ..salt = AuthUtility.generateRandomSalt()
      ..hashedPassword = authServer.hashPassword(user.password, user.salt);

//Если поле companyName пустое - создается пользователь для ТСД
    if (customerName == null) {
      try {
        final User createdUser = await Query(context, values: user).insert();
        MailService.mailRegisterUser(user);
        final q = Query<User>(context)
          ..where((u) => u.id).equalTo(createdUser.id)
          ..join(object: (u) => u.vendor)
          ..join(object: (u) => u.customer);

        return Response.ok(await q.fetchOne());
      } catch (e) {
        print('error: $e');
        return Response.unauthorized();
      }
    }
//Иначе создается новый пользователь и организация
    else {
      String schemaCode;
      Customer newCustomer;
//Создаем новую запись в справочнике Customer
      var query = Query<Customer>(context)..values.customer = customerName;
      try {
        newCustomer = await query.insert();
        schemaCode = newCustomer.id.toString();
      } catch (e) {
        print('error: $e');
      }
      //Создаем новую схему
      try {
        await context.persistentStore
            .executeQuery('CREATE SCHEMA IF NOT EXISTS "$schemaCode"', {}, 60);

        await context.persistentStore.executeQuery(
            'CREATE TABLE "$schemaCode".company (LIKE public.company INCLUDING ALL)',
            {},
            60);
        await context.persistentStore.executeQuery(
            'CREATE TABLE "$schemaCode".dm (LIKE public.dm INCLUDING ALL)',
            {},
            60);
        await context.persistentStore.executeQuery(
            'CREATE TABLE "$schemaCode".ean (LIKE public.ean INCLUDING ALL)',
            {},
            60);
        await context.persistentStore.executeQuery(
            'CREATE TABLE "$schemaCode".packlist (LIKE public.packlist INCLUDING ALL)',
            {},
            60);
      } catch (e) {
        print('error: $e');
      }
//Создаем нового пользователя и пишем customer id
      try {
        user.customer = newCustomer;
        final User createdUser = await Query(context, values: user).insert();
 //Отправляем email      
        MailService.mailRegisterUser(user);

        final q = Query<User>(context)
          ..where((u) => u.id).equalTo(createdUser.id)
          ..join(object: (u) => u.vendor)
          ..join(object: (u) => u.customer);

        return Response.ok(await q.fetchOne());
      } catch (e) {
        print('error: $e');
        return Response.unauthorized();
      }
    }
  }
}
