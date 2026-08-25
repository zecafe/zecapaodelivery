import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core.dart';

class DeliveryPoint {
  final double latitude;
  final double longitude;
  const DeliveryPoint(this.latitude, this.longitude);
  String get label => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

class DeliveryLocationPickerPage extends StatefulWidget {
  const DeliveryLocationPickerPage({super.key});
  @override State<DeliveryLocationPickerPage> createState()=>_DeliveryLocationPickerPageState();
}

class _DeliveryLocationPickerPageState extends State<DeliveryLocationPickerPage> {
  static const valeDoCapao=LatLng(-12.6115,-41.4946);
  LatLng selected=valeDoCapao;
  GoogleMapController? controller;
  bool locating=false,permissionReady=false,mapReady=false;
  String? message;

  @override void initState(){super.initState();_bootstrap();}

  Future<void> _bootstrap() async {
    final prefs=await SharedPreferences.getInstance();
    final lat=prefs.getDouble('zecapao_latitude'),lng=prefs.getDouble('zecapao_longitude');
    if(lat!=null&&lng!=null&&mounted)setState(()=>selected=LatLng(lat,lng));
    await _useCurrentLocation(initial:true);
  }

  Future<void> _save(LatLng point) async {
    final prefs=await SharedPreferences.getInstance();
    await prefs.setDouble('zecapao_latitude',point.latitude);
    await prefs.setDouble('zecapao_longitude',point.longitude);
    await prefs.setInt('zecapao_location_at',DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _useCurrentLocation({bool initial=false}) async {
    if(!initial&&mounted)setState(()=>locating=true);
    try{
      if(!await Geolocator.isLocationServiceEnabled()){
        if(mounted)setState(()=>message='Ative a localização do celular ou marque o ponto manualmente.');
        return;
      }
      var permission=await Geolocator.checkPermission();
      if(permission==LocationPermission.denied)permission=await Geolocator.requestPermission();
      if(permission==LocationPermission.denied||permission==LocationPermission.deniedForever){
        if(mounted)setState(()=>message='Permissão não concedida. O mapa continua disponível para marcação manual.');
        return;
      }
      if(mounted)setState(()=>permissionReady=true);
      final pos=await Geolocator.getCurrentPosition(locationSettings:const LocationSettings(accuracy:LocationAccuracy.high,timeLimit:Duration(seconds:12)));
      final point=LatLng(pos.latitude,pos.longitude);
      await _save(point);
      if(!mounted)return;
      setState((){selected=point;message=null;});
      if(mapReady)await controller?.animateCamera(CameraUpdate.newLatLngZoom(point,17));
    }catch(_){if(mounted)setState(()=>message='GPS indisponível agora. Você pode marcar o ponto manualmente.');}
    finally{if(mounted)setState(()=>locating=false);}
  }

  Future<void> _mapCreated(GoogleMapController c) async {
    controller=c;mapReady=true;
    await c.animateCamera(CameraUpdate.newLatLngZoom(selected,selected==valeDoCapao?15:17));
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Onde entregar?')),
    body:Stack(children:[
      GoogleMap(
        initialCameraPosition:CameraPosition(target:selected,zoom:15),
        myLocationEnabled:permissionReady,
        myLocationButtonEnabled:false,
        zoomControlsEnabled:false,
        compassEnabled:true,
        mapToolbarEnabled:false,
        onMapCreated:_mapCreated,
        onTap:(p){setState(()=>selected=p);_save(p);},
        markers:{Marker(markerId:const MarkerId('delivery'),position:selected,draggable:true,onDragEnd:(p){setState(()=>selected=p);_save(p);})},
      ),
      Positioned(left:16,right:16,top:16,child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),boxShadow:const [BoxShadow(color:Color(0x22000000),blurRadius:18)]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Marque o ponto exato',style:TextStyle(fontSize:16,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(message??'Sua localização foi carregada. Ajuste o marcador se necessário.',style:const TextStyle(color:brandMuted,fontSize:12))]))),
      Positioned(right:16,bottom:96,child:FloatingActionButton.small(heroTag:'gps',backgroundColor:Colors.white,foregroundColor:brandRed,onPressed:locating?null:()=>_useCurrentLocation(),child:locating?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.my_location_rounded))),
      Positioned(left:16,right:16,bottom:18,child:FilledButton.icon(onPressed:() async {await _save(selected);if(context.mounted)Navigator.pop(context,DeliveryPoint(selected.latitude,selected.longitude));},icon:const Icon(Icons.check_circle_outline_rounded),label:const Text('CONFIRMAR LOCAL DE ENTREGA'))),
    ])
  );
}
