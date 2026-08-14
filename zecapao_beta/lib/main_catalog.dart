import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'catalog/core.dart';
import 'catalog/branded_home.dart';

const supabaseUrl='https://yovjbqtazkreruvxoawf.supabase.co';
const supabasePublishableKey='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvdmpicXRhemtyZXJ1dnhvYXdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1NjA1NTgsImV4cCI6MjEwMjEzNjU1OH0.4uwUVON1aNdH1D1UKMzNaOn5xplGf1ffwNkcwSw_30U';

Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url:supabaseUrl,publishableKey:supabasePublishableKey);
  runApp(const CatalogApp());
}

class CatalogApp extends StatelessWidget{
  const CatalogApp({super.key});
  @override
  Widget build(BuildContext context){
    final base=ThemeData(useMaterial3:true,brightness:Brightness.light);
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title:'Zé Capão Delivery',
      theme:base.copyWith(
        scaffoldBackgroundColor:appBg,
        colorScheme:const ColorScheme.light(primary:brandRed,secondary:brandYellow,surface:Colors.white,error:brandRed,onPrimary:Colors.white,onSecondary:brandInk,onSurface:brandInk),
        textTheme:GoogleFonts.poppinsTextTheme(base.textTheme).apply(bodyColor:brandInk,displayColor:brandInk),
        appBarTheme:AppBarTheme(backgroundColor:appBg,surfaceTintColor:Colors.transparent,elevation:0,centerTitle:false,titleTextStyle:GoogleFonts.poppins(fontSize:18,fontWeight:FontWeight.w800,color:brandInk),iconTheme:const IconThemeData(color:brandInk)),
        cardTheme:CardThemeData(color:Colors.white,elevation:0,margin:EdgeInsets.zero,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(22))),
        filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(backgroundColor:brandRed,foregroundColor:Colors.white,minimumSize:const Size(48,52),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),textStyle:GoogleFonts.poppins(fontWeight:FontWeight.w800))),
        inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,hintStyle:GoogleFonts.poppins(color:brandMuted),labelStyle:GoogleFonts.poppins(color:brandMuted),border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:const BorderSide(color:Color(0x11000000))),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:const BorderSide(color:brandRed,width:1.5)),contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:16)),
        navigationBarTheme:NavigationBarThemeData(backgroundColor:Colors.white,indicatorColor:brandRedSoft,height:70,labelTextStyle:WidgetStatePropertyAll(GoogleFonts.poppins(fontSize:11,fontWeight:FontWeight.w700)),iconTheme:WidgetStateProperty.resolveWith((states)=>IconThemeData(color:states.contains(WidgetState.selected)?brandRed:brandInk.withValues(alpha:.62)))),
        chipTheme:ChipThemeData(backgroundColor:Colors.white,selectedColor:brandRed,secondarySelectedColor:brandRed,labelStyle:GoogleFonts.poppins(fontSize:12,fontWeight:FontWeight.w700),secondaryLabelStyle:GoogleFonts.poppins(fontSize:12,fontWeight:FontWeight.w700,color:Colors.white),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),side:BorderSide.none),
      ),
      home:const BrandedSignupPage(),
    );
  }
}
