import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_messaging_app/main.dart';
import 'package:flutter_messaging_app/Pages/SignUpScreen.dart';


var MainActivityRoute = <String,WidgetBuilder>
{

  '/SignUpScreen': (BuildContext contaxt) => SignUpScreen()
};

//Future<void> main() async {
//  runApp(new MaterialApp(
//    theme:
//    ThemeData(primaryColor: Colors.green, accentColor: Colors.green),
//    debugShowCheckedModeBanner: false,
//    home: MapsDemo(),
//    routes: MainActivityRoute,
//
//  ));
//}

class MapsDemo extends StatefulWidget {
  @override
  MapsDemoState createState() => MapsDemoState();
}

class MapsDemoState extends State<MapsDemo> {
  //
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(33.6844, -122.677433);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;



  static final CameraPosition _position1 = CameraPosition(
    bearing: 192.833,
    target: LatLng(33.6844, 73.0479),
    tilt: 59.440,
    zoom: 11.0,
  );

  Future<void> _goToPosition1() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position1));
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(_lastMapPosition.toString()),
          position: _lastMapPosition,
          infoWindow: InfoWindow(
            title: 'Ground Location',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );

      double lat = _lastMapPosition.latitude;
      double longitude = _lastMapPosition.longitude;

      user_defualts.saveGroundLocation(lat, longitude);
      Fluttertoast.showToast(
          msg: "Location Choose and Save Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1
      );

      String latlng =lat.toString()+","+longitude.toString();
      if (Navigator.canPop(context)) {
        Navigator.pop(context,latlng);
      } else {
        //SystemNavigator.pop();
      }

    });
  }

  Widget button(Function function, IconData icon,String tag) {
    return FloatingActionButton(
      heroTag: tag,
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.white,
      child: Icon(
        icon,
        color: Colors.green,
        size: 36.0,
      ),
    );
  }
  User_Defualts user_defualts = new User_Defualts();

  @override
  void initState() {
    // TODO: implement initState
    _goToPosition1();
    user_defualts.saveGroundLocation(0.0, 0.0);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Add You Location",style: TextStyle(color: Colors.green),),
          backgroundColor: Colors.white,
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              mapType: _currentMapType,
              markers: _markers,
              onCameraMove: _onCameraMove,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 30.0),
              child: Align(
              alignment: Alignment.bottomCenter,
                child: Text("Add Location by using center marker and Second Button on Right",textAlign: TextAlign.center,style: TextStyle(color: Colors.green,fontSize: 22.0,fontWeight: FontWeight.bold),),
            ),),
            Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.location_on,
                color: Colors.green,
                size: 35.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: <Widget>[
                    button(_onMapTypeButtonPressed, Icons.map,"map"),
                    SizedBox(
                      height: 16.0,
                    ),
                    button(_onAddMarkerButtonPressed, Icons.add_location,"add_location"),
                    SizedBox(
                      height: 16.0,
                    ),
                    button(_goToPosition1, Icons.location_searching,"home_location"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
