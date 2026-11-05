import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/app_theme.dart';
import 'cubits/store_cubit.dart';
import 'services/supabase_service.dart';
import 'views/storefront_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const RuposhiCustomerApp());
}

class RuposhiCustomerApp extends StatelessWidget {
  final StoreCubit? cubit;
  const RuposhiCustomerApp({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => cubit ?? StoreCubit(),
      child: MaterialApp(
        title: 'Ruposhi International | Premier Luxury Cosmetics Importer in Bangladesh',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const StorefrontShell(),
      ),
    );
  }
}
