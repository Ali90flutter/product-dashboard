import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'features/product/data/datasources/product_local_datasource.dart';
import 'features/product/data/datasources/product_remote_datasource.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/presentation/blocs/product_cubit.dart';

void main() {
  final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

  final ProductRemoteDataSource remote = ProductRemoteDataSourceImpl(dio);
  final ProductLocalDataSource local = ProductLocalDataSourceImpl();

  final ProductRepository repo = ProductRepositoryImpl(
    remote: remote,
    local: local,
  );

  runApp(App(repo: repo));
}

class App extends StatelessWidget {
  final ProductRepository repo;
  const App({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProductCubit(repo)),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        routerConfig: appRouter,
      ),
    );
  }
}
