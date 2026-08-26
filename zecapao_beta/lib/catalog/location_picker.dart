import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
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
  final mapController=MapController();
  LatLng selected=valeDoCapao;
  bool locating=false,mapReady=false;
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
        if(mounted)setState(()=>message='Permissão não concedida. Você ainda pode marcar o ponto manualmente.');
        return;
      }
      final pos=await Geolocator.getCurrentPosition(locationSettings:const LocationSettings(accuracy:LocationAccuracy.high,timeLimit:Duration(seconds:12)));
      final point=LatLng(pos.latitude,pos.longitude);
      await _save(point);
      if(!mounted)return;
      setState((){selected=point;message=null;});
      if(mapReady)mapController.move(point,17);
    }catch(_){
      if(mounted)setState(()=>message='GPS indisponível agora. Você pode marcar o ponto manualmente.');
    }finally{
      if(mounted)setState(()=>locating=false);
    }
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Onde entregar?')),
    body:Stack(children:[
      FlutterMap(
        mapController:mapController,
        options:MapOptions(
          initialCenter:selected,
          initialZoom:15,
          minZoom:3,
          maxZoom:19,
          onMapReady:(){mapReady=true;mapController.move(selected,selected==valeDoCapao?15:17);},
          onTap:(_,p){setState(()=>selected=p);_save(p);},
        ),
        children:[
          TileLayer(
            urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:'com.zecapao.entrega',
            maxNativeZoom:19,
          ),
          MarkerLayer(markers:[
            Marker(
              point:selected,
              width:56,
              height:56,
              child:const Icon(Icons.location_pin,color:brandRed,size:52),
            )
          ]),
          RichAttributionWidget(attributions:[TextSourceAttribution('OpenStreetMap contributors')]),
        ],
      ),
      Positioned(left:16,right:16,top:16,child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),boxShadow:const [BoxShadow(color:Color(0x22000000),blurRadius:18)]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Marque o ponto exato',style:TextStyle(fontSize:16,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(message??'Sua localização foi carregada. Toque no mapa para ajustar o ponto.',style:const TextStyle(color:brandMuted,fontSize:12))]))),
      Positioned(right:16,bottom:96,child:FloatingActionButton.small(heroTag:'gps',backgroundColor:Colors.white,foregroundColor:brandRed,onPressed:locating?null:()=>_useCurrentLocation(),child:locating?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.my_location_rounded))),
      Positioned(left:16,right:16,bottom:18,child:FilledButton.icon(onPressed:() async {await _save(selected);if(context.mounted)Navigator.pop(context,DeliveryPoint(selected.latitude,selected.longitude));},icon:const Icon(Icons.check_circle_outline_rounded),label:const Text('CONFIRMAR LOCAL DE ENTREGA'))),
    ])
  );
}
