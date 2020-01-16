import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_map/coffee_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController _controller;
  PageController _pageController;

  List<Marker> allMarkers = [];

  int prevPage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    coffeeShops.forEach((element) {
      allMarkers.add(Marker(
        markerId: MarkerId(element.shopName),
        draggable: false,
        infoWindow: InfoWindow(title: element.shopName, snippet: element.address),
        position: element.locationCoords
      ));
    });

    _pageController = PageController(initialPage: 1, viewportFraction: 0.8)..addListener(_onScroll);
  }

  void _onScroll() {
    if(_pageController.page.toInt() != prevPage) {
      prevPage =_pageController.page.toInt();
      moveCamera();
    }
  }

  _coffeeShopList(index) {
    return AnimatedBuilder(
        animation: _pageController,
        builder: (BuildContext contex, Widget widget) {
          double value = 1;

          if(_pageController.position.haveDimensions) {
            value = _pageController.page - index;
            value = (1-(value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
          }

          return Center(
            child: SizedBox(
              height: Curves.easeInOut.transform(value) * 250.0,
              width: Curves.easeInOut.transform(value) * 350.0,
              child: widget,
            ),
          );
        },

      child: InkWell(
        onTap: () {
          moveCamera();
        },
        child: Stack(
          children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 20.0
                ),
                height: 100.0,
                width: 275.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0.0, 4.0),
                      blurRadius: 10.0
                    )
                  ]
                ),

                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0)
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              coffeeShops[index].thumbNail
                            ),
                            fit: BoxFit.contain
                          )
                        ),
                      ),

                      SizedBox(
                        width: 5.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            coffeeShops[index].shopName,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            coffeeShops[index].address,
                            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                          ),

                          Container(
                            width: 170.0,
                            child: Text(
                              coffeeShops[index].description,
                              style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w300),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Maps"),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height - 50.0,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(40.7128, -74.0060), zoom: 12.0
              ),
              markers: Set.from(allMarkers),
              onMapCreated: mapCreated,
            ),
          ),

          Positioned(
            bottom: 20.0,
            child: Container(
              height: 200.0,
              width: MediaQuery.of(context).size.width,
              child: PageView.builder(
                  controller: _pageController,
                itemCount: coffeeShops.length,
                itemBuilder: (BuildContext contex, int index) {
                    return _coffeeShopList(index);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  moveCamera() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: coffeeShops[_pageController.page.toInt()].locationCoords,
        zoom: 14.0,
        bearing: 45.0,
        tilt: 45.0
      )
    ));
  }
}
