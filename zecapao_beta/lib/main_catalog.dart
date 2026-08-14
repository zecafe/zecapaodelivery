import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'catalog/core.dart';
import 'catalog/home.dart';

const supabaseUrl='https://yovjbqtazkreruvxoawf.supabase.co';
const supabasePublishableKey='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvdmpicXRhemtyZXJ1dnhvYXdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1NjA1NTgsImV4cCI6MjEwMjEzNjU1OH0.4uwUVON1aNdH1D1UKMzNaOn5xplGf1ffwNkcwSw_30U';
Future<void> main()async{WidgetsFlutterBinding.ensureInitialized();await Supabase.initialize(url:supabaseUrl,publishableKey:supabasePublishableKey);runApp(const CatalogApp());}
class CatalogApp extends StatelessWidget{const CatalogApp({super.key});@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Zé Capão Delivery',theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:bg,colorScheme:ColorScheme.fromSeed(seedColor:red,primary:red,secondary:yellow),inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder())),home:const SignupPage());}
