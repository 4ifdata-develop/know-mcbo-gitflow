import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:know_my_city/application/sign_in/sign_in_bloc.dart';
import 'package:know_my_city/injection.dart';
import 'package:know_my_city/presentation/core/directions_model.dart';
import 'package:know_my_city/presentation/core/theme_core.dart';
import 'package:know_my_city/presentation/dialogs/qrcode_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:know_my_city/presentation/core/directions_repository.dart';
import 'package:know_my_city/presentation/core/app_theme.dart';
import 'package:know_my_city/presentation/core/router_core.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  List<BitmapDescriptor> _customIcons = [];
  late GoogleMapController _mapController;
  late Marker _tranvia;
  late Marker _plaza;
  late Marker _casaCapitulacion;
  late Marker _hospitalCentral;
  late Marker _quintaLuxor;
  Directions? _info;
  Set<Polyline> _polylines = {};
  bool rutaSeleccionada = false;
  String rutaQR = '';

/*   @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  } */

  late Future<String> _mapStyle;

  final LatLng _center = const LatLng(10.660844651881145, -71.59921476991683);
  final LatLng _tranviaPosition =
      const LatLng(10.6564178133895, -71.59488684178918);
  final LatLng _plazaPosition =
      const LatLng(10.66623260705817, -71.60581323765165);
  final LatLng _costaVerdePosition =
      const LatLng(10.678566872849304, -71.60681026461249);
  final LatLng _deliciasPlazaPosition =
      const LatLng(10.685911973418046, -71.62544140660783);
  final LatLng _casaCapitulacionPosition =
      const LatLng(10.64231896416391, -71.60783610049393);
  final LatLng _quintaLuxorPosition =
      const LatLng(10.666711923974145, -71.6317473478305);
  final LatLng _hospitalCentralPosition =
      const LatLng(10.64214695401155, -71.60557377666612);

  late SignInBloc _signInBloc;
  @override
  void initState() {
    super.initState();
    _signInBloc = sl<SignInBloc>();
    _mapStyle = _loadMapStyle();
    _loadCustomMarkerIcons();
    _initializeMarkers();
    _info = null; // This line can be removed as _info is now nullable
    /* _loadDirections(); */
  }

  Future<void> _loadCustomMarkerIcons() async {
    List<String> iconPaths = [
      'assets/tranvia.png',
      'assets/plaza.png',
      'assets/casa.png',
      'assets/central.png'
    ];

    for (String path in iconPaths) {
      BitmapDescriptor icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(40, 40)),
        path,
      );
      _customIcons.add(icon);
    }

    setState(() {});
  }

  void _initializeMarkers() {
    _tranvia = Marker(
      markerId: const MarkerId('tranvia'),
      position: const LatLng(10.6564178133895,
          -71.59488684178918), // Ajusta la posición según sea necesario
      icon: _customIcons.isNotEmpty
          ? _customIcons[0]
          : BitmapDescriptor.defaultMarker,
    );

    _plaza = Marker(
      markerId: const MarkerId('plaza'),
      position: const LatLng(10.66623260705817,
          -71.60581323765165), // Ajusta la posición según sea necesario
      icon: _customIcons.length > 1
          ? _customIcons[1]
          : BitmapDescriptor.defaultMarker,
    );

    _casaCapitulacion = Marker(
      markerId: const MarkerId('casaCapitulacion'),
      position: const LatLng(10.64231896416391,
          -71.60783610049393), // Ajusta la posición según sea necesario
      icon: _customIcons.length > 2
          ? _customIcons[2]
          : BitmapDescriptor.defaultMarker,
    );

    _hospitalCentral = Marker(
      markerId: const MarkerId('hospitalCentral'),
      position: const LatLng(10.64214695401155,
          -71.60557377666612), // Ajusta la posición según sea necesario
      icon: _customIcons.length > 3
          ? _customIcons[3]
          : BitmapDescriptor.defaultMarker,
    );

    _quintaLuxor = Marker(
      markerId: const MarkerId('quintaLuxor'),
      position: const LatLng(10.666711923974145,
          -71.6317473478305), // Ajusta la posición según sea necesario
      icon: _customIcons.length > 4
          ? _customIcons[2]
          : BitmapDescriptor.defaultMarker,
    );

    setState(() {});
  }

  /*  Future<void> _loadDirections() async {
    final directions = await DirectionsRepository()
        .getDirections(origin: _tranvia.position, destination: _plaza.position, tranvia: _tranvia.position, plaza: _plaza.position);
    setState(() => _info = directions);
  } */

  Future<String> _loadMapStyle() async {
    return await rootBundle.loadString('lib/presentation/core/map_style.json');
  }

  void _goToLocation(LatLng position) {
    if (_mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 18.0,
          ),
        ),
      );
    }
  }

  void _goToCenter(LatLng position) {
    if (_mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: position,
          zoom: 14,
        )),
      );
    }
  }

  void _reservaTranvia(String ruta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QRCodeGenerator(ruta: rutaQR);
      },
    );
  }

  void _seleccionarRuta(String nombreRuta) {
    setState(() {
      rutaSeleccionada = true;
      rutaQR = nombreRuta;
    });
  }

  void _limpiarRuta(Set<Polyline> polylines) {
    setState(() {
      polylines.clear();
      rutaSeleccionada = false;
    });
  }

  void _showCustomInfoWindow(BuildContext context, String title, String ruta,
      String snippet, String assetname) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      customHeader: ClipOval(
        child: Image.asset(
          'assets/$assetname.png',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
      title: title,
      titleTextStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'alcaldia_fonts',
      ),
      descTextStyle: const TextStyle(
        fontSize: 16,
        fontFamily: 'alcaldia_fonts',
      ),
      desc: ruta.substring(0, 4).toLowerCase() == 'ruta'
          ? '$snippet\n\n Visita este lugar en las siguientes rutas: $ruta'
          : snippet,
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(24),
      headerAnimationLoop: false,
      showCloseIcon: true,
      /* btnCancelText: 'Cerrar',
      btnCancelOnPress: () {},
      btnOkText: 'Dibujar Ruta',
      btnOkOnPress: () {    
        if (ruta == 'Ruta de la Alegría') {
          _drawMultiplePolylines();
        } else if (ruta == 'Ruta del Terror') {
        _drawTerrorRoute();
        }        
      }, */
    ).show();
  }

  /* Future<void> _drawPolylines() async {
    try {
      final directions = await DirectionsRepository().getDirections(
        origin: _tranvia.position,
        destination: _plaza.position,
      );

      if (directions != null) {
        setState(() {
          _polylines.add(
            Polyline(
              polylineId: PolylineId('ruta_alegria'),
              points: directions,
              color: const Color.fromARGB(255, 54, 209, 59),
              width: 5,
            ),
          );
        });

        print('Polylines drawn: $_polylines'); // Agrega este print para verificar las polylines dibujadas
      }
    } catch (e) {
      print('Error drawing polylines: $e');
    }
  } */

  Future<void> _drawTerrorRoute() async {
    try {
      final routes = [
        {'origin': _tranviaPosition, 'destination': _hospitalCentralPosition},
        {
          'origin': _hospitalCentralPosition,
          'destination': _casaCapitulacionPosition
        },
        {
          'origin': _casaCapitulacionPosition,
          'destination': _quintaLuxorPosition
        },
      ];

      final directions = await DirectionsRepository().getDirections(
        routes: routes,
      );

      setState(() {
        _polylines.clear();
        for (int i = 0; i < directions.length; i++) {
          _polylines.add(
            Polyline(
              polylineId: PolylineId('terror_route_$i'),
              points: directions[i],
              color: const Color.fromARGB(
                  255, 249, 26, 10), // Color para la ruta del terror
              width: 5,
            ),
          );
        }
      });

      /* print('Polylines drawn: $_polylines'); */ // Agrega este print para verificar las polylines dibujadas
    } catch (e) {
      print('Error drawing polylines: $e');
    }
  }

  Future<void> _drawMultiplePolylines() async {
    try {
      final routes = [
        {'origin': _tranvia.position, 'destination': _plaza.position},
        {'origin': _plazaPosition, 'destination': _costaVerdePosition},
        {'origin': _costaVerdePosition, 'destination': _deliciasPlazaPosition},
      ];

      final directions =
          await DirectionsRepository().getDirections(routes: routes);

      setState(() {
        _polylines.clear();
        for (int i = 0; i < directions.length; i++) {
          _polylines.add(
            Polyline(
              polylineId: PolylineId('route_$i'),
              points: directions[i],
              color: Colors.green,
              width: 5,
            ),
          );
        }
      });

      /* print('Polylines drawn: $_polylines'); */ // Agrega este print para verificar las polylines dibujadas
    } catch (e) {
      print('Error drawing polylines: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      bloc: _signInBloc,
      builder: (context, state) {
        if (state.isSubmitting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return FutureBuilder<String>(
            future: _mapStyle,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading map style'));
              } else {
                return MainMaps(
                    polylines: _polylines,
                    signInBloc: _signInBloc,
                    center: _center,
                    mapStyle: snapshot.data!,
                    customIcons: _customIcons,
                    goToLocation: _goToLocation,
                    goToCenter: _goToCenter,
                    drawTerrorRoute: _drawTerrorRoute,
                    drawPolylines: _drawMultiplePolylines,
                    tranvia: _tranvia,
                    plaza: _plaza,
                    hospitalCentral: _hospitalCentral,
                    casaCapitulacion: _casaCapitulacion,
                    quintaLuxor: _quintaLuxor,
                    info: _info,
                    showCustomInfoWindow:
                        (context, title, ruta, snippet, assetname) =>
                            _showCustomInfoWindow(
                                context, title, ruta, snippet, assetname),
                    reservaTranvia: _reservaTranvia,
                    seleccionarRuta: _seleccionarRuta,
                    limpiarRuta: _limpiarRuta,
                    rutaSeleccionada: rutaSeleccionada,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      // ignore: deprecated_member_use
                      _mapController.setMapStyle(snapshot.data!);
                    });
              }
            },
          );
        }
      },
    );
  }
}

class MainMaps extends StatelessWidget {
  MainMaps({
    super.key,
    required this.quintaLuxor,
    required this.casaCapitulacion,
    required this.hospitalCentral,
    required this.tranvia,
    required this.plaza,
    required this.info,
    required this.signInBloc,
    required this.center,
    required this.mapStyle,
    required this.customIcons,
    required this.goToLocation,
    required this.goToCenter,
    required this.drawTerrorRoute,
    required this.drawPolylines,
    required this.onMapCreated,
    required this.showCustomInfoWindow,
    required this.polylines,
    required this.reservaTranvia,
    required this.seleccionarRuta,
    required this.limpiarRuta,
    required this.rutaSeleccionada,
  });

  final SignInBloc signInBloc;
  final Set<Polyline> polylines;
  final LatLng center;
  final String mapStyle;
  final Directions? info; // Make the info parameter nullable
  Marker casaCapitulacion;
  Marker quintaLuxor;
  Marker hospitalCentral;
  Marker tranvia;
  Marker plaza;
  final List<BitmapDescriptor> customIcons;
  final Function drawTerrorRoute;
  final Function drawPolylines;
  final Function(String) seleccionarRuta;
  final Function limpiarRuta;
  final Function reservaTranvia;
  final Function(LatLng) goToLocation;
  final Function(LatLng) goToCenter;
  final Function(GoogleMapController) onMapCreated;
  final void Function(BuildContext, String, String, String, String)
      showCustomInfoWindow;
  final bool rutaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double width = constraints.maxWidth;
      return Scaffold(
          appBar: AppBar(
            leadingWidth: 0.0271 * (width),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  "images/brand/fomutur.png", // Corregida la ruta de la imagen
                  width: 0.1448 * (width),
                  height: 0.0397 * (width),
                  //fit: BoxFit.contain,
                ),
              ],
            ),
            toolbarHeight: 0.0549 * (width),
            backgroundColor: Colors.white,
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    child: SizedBox(
                      height: 0.0549 * (width),
                      //width: 0.0549 * (width),
                      child: Center(
                        child: Text(
                          '¿Quiénes somos?',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 0.0185 * (width),
                            fontFamily: 'alcaldia_fonts',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      context.go('/maps');
                      print('¿Quiénes somos?');
                    },
                  ),
                  SizedBox(
                    height: 0.0549 * (width),
                    width: 0.0549 * (width),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          context.go('/');
                        },
                        iconSize: 0.0355 * (width),
                        color: AppTheme.primaryColor,
                        icon: const Icon(Icons.home),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 0.0549 * (width),
                    width: 0.0549 * (width),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          print('Persona perfil');
                        },
                        iconSize: 0.0355 * (width),
                        color: AppTheme.primaryColor,
                        icon: const Icon(Icons.person),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 0.0549 * (width),
                    width: 0.0549 * (width),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          context.go('/maps');
                        },
                        iconSize: 0.0355 * (width),
                        color: AppTheme.primaryColor,
                        icon: const Icon(Icons.location_on),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 0.0549 * (width),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          print('Persona ayuda');
                        },
                        iconSize: 0.0355 * (width),
                        color: AppTheme.primaryColor,
                        icon: const Icon(Icons.help),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: ThemeCore.primaryColor,
                  ),
                  child: Text(
                    'Rutas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ExpansionTile(
                  title: Text('Rutas del Tranvía'),
                  children: <Widget>[
                    ListTile(
                      title: Text('Ruta de la Alegría'),
                      subtitle: Text('Vive la experiencia de rascarte'),
                    ),
                    ListTile(
                      title: Text('Ruta del Sexo'),
                      subtitle: Text('Explora las calles de la pasión'),
                    ),
                    ListTile(
                      title: Text('Ruta Gastronómica'),
                      subtitle: Text('Sabores locales'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Row(
            children: [
              if (MediaQuery.of(context).size.width > 700)
                Expanded(
                  flex: 1,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(16.0),
                        color: ThemeCore.primaryColor,
                        child: const Text(
                          'Rutas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                      ),
                      ExpansionTile(
                        title: const Text(
                          'Tranvía',
                          style: TextStyle(fontSize: 18),
                        ),
                        children: <Widget>[
                          ListTile(
                            title: Text('Ruta de la Alegría'),
                            subtitle:
                                Text('Disfruta de la ciudad por la noche'),
                            onTap: () {
                              drawPolylines();
                              seleccionarRuta('Ruta de la Alegría');
                              goToCenter(center);
                            },
                          ),
                          ListTile(
                            title: Text('Ruta del Terror'),
                            subtitle: Text('Disfruta de la noche marabina'),
                            onTap: () {
                              drawTerrorRoute();
                              seleccionarRuta('Ruta del Terror');
                              goToCenter(center);
                            },
                          ),
                          ListTile(
                            title: Text('Ruta Gastronómica'),
                            subtitle: Text('Tequeyoyos, empanadas, arepas'),
                            onTap: () {
                              // Acción para esta ruta
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: const Text(
                          'Fomutur',
                          style: TextStyle(fontSize: 18),
                        ),
                        children: <Widget>[
                          ListTile(
                            title: Text('Ruta de la Comida'),
                            subtitle:
                                Text('Disfruta de la gastronomía zuliana'),
                            onTap: () {
                              signInBloc.add(const SignInEvent.singInEmail());
                            },
                          ),
                          ListTile(
                            title: Text('Ruta de la Marina'),
                            subtitle: Text('Disfruta de la brisa marina'),
                            onTap: () {
                              // Acción para esta ruta
                            },
                          ),
                          ListTile(
                            title: Text('Ruta de el centro'),
                            subtitle:
                                Text('Disfruta de la arquitectura antigua'),
                            onTap: () {
                              // Acción para esta ruta
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: const Text(
                          'Lacustres',
                          style: TextStyle(fontSize: 18),
                        ),
                        children: <Widget>[
                          ListTile(
                            title: Text('San Carlos'),
                            subtitle: Text('Disfruta de la naturaleza'),
                            onTap: () {
                              signInBloc.add(const SignInEvent.singInEmail());
                            },
                          ),
                          ListTile(
                            title: Text('Isla de Toas'),
                            subtitle: Text('La isla de los pescadores'),
                            onTap: () {
                              // Acción para esta ruta
                            },
                          ),
                          ListTile(
                            title: Text('Isla de Zapara'),
                            subtitle: Text('Disfruta de la naturaleza'),
                            onTap: () {
                              // Acción para esta ruta
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: rutaSeleccionada
                              ? () => reservaTranvia('ruta')
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: rutaSeleccionada
                                ? ThemeCore.primaryColor
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            textStyle: const TextStyle(
                                fontSize: 16, color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Adquiere tus entradas'),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                  flex: 3, // Ajusta el tamaño del mapa
                  child: Stack(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GoogleMap(
                            onMapCreated: onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: center,
                              zoom: 14,
                            ),
                            markers: {
                              tranvia = Marker(
                                markerId:
                                    const MarkerId('Tranvía de Maracaibo'),
                                position: const LatLng(
                                    10.6564178133895, -71.59488684178918),
                                icon: customIcons.isNotEmpty
                                    ? customIcons[0]
                                    : BitmapDescriptor.defaultMarker,
                                onTap: () {
                                  /* goToLocation(
                                const LatLng(10.6564178133895, -71.59488684178918)
                              ); */
                                  showCustomInfoWindow(
                                      context,
                                      'Tranvía de Maracaibo',
                                      'Sede',
                                      'Sede del tranvía de Maracaibo, punto de salida para las rutas del Tranvía, ¡Descubre nuestras rutas en el menú lateral!',
                                      'tranvia'); //MUESTRA EL INFOWINDOW CON CLICK
                                },
                              ),
                              plaza = Marker(
                                markerId:
                                    const MarkerId('Plaza de la Republica'),
                                position: const LatLng(
                                    10.66623260705817, -71.60581323765165),
                                icon: customIcons.isNotEmpty
                                    ? customIcons[1]
                                    : BitmapDescriptor.defaultMarker,
                                onTap: () {
                                  /* goToLocation(
                                const LatLng(10.665841201331798, -71.60603111374822)
                              ); */
                                  showCustomInfoWindow(
                                      context,
                                      'Plaza de la República',
                                      'Ruta de la Alegría',
                                      'La plaza de la República es una de las principales plazas de la ciudad de Maracaibo, está ubicada en la calle 5 de Julio, un importante bulevar de Maracaibo, que lleva el nombre de la fecha de la independencia de Venezuela.',
                                      'plaza');
                                  /* showCustomInfoWindow(context, 'Tranvía de Maracaibo', 'Sede del tranvía de Maracaibo'); */ //MUESTRA EL INFOWINDOW CON CLICK
                                },
                              ),
                              hospitalCentral = Marker(
                                markerId: const MarkerId('Hospital Central'),
                                position: const LatLng(
                                    10.64214695401155, -71.60557377666612),
                                icon: customIcons.isNotEmpty
                                    ? customIcons[3]
                                    : BitmapDescriptor.defaultMarker,
                                onTap: () {
                                  /* goToLocation(
                                const LatLng(10.64214695401155, -71.60557377666612)
                              ); */
                                  showCustomInfoWindow(
                                      context,
                                      'Hospital Central',
                                      'Ruta del Terror',
                                      'El Hospital Central de Maracaibo es uno de los centros de salud más antiguos de la ciudad de Maracaibo. Fue la sede del primer hospital de la ciudad creado como la "Casa de Beneficencia" pero también recibió el nombre de Hospital de Santa Ana, siendo inaugurado el 26 de julio de 1608.',
                                      'central');
                                  /* showCustomInfoWindow(context, 'Tranvía de Maracaibo', 'Sede del tranvía de Maracaibo'); */ //MUESTRA EL INFOWINDOW CON CLICK
                                },
                              ),
                              casaCapitulacion = Marker(
                                markerId:
                                    const MarkerId('Casa de la Capitulación'),
                                position: const LatLng(
                                    10.64231896416391, -71.60783610049393),
                                icon: customIcons.isNotEmpty
                                    ? customIcons[2]
                                    : BitmapDescriptor.defaultMarker,
                                onTap: () {
                                  goToLocation(const LatLng(
                                      10.64231896416391, -71.60783610049393));
                                  /* showCustomInfoWindow(context, 'Tranvía de Maracaibo', 'Sede del tranvía de Maracaibo'); */ //MUESTRA EL INFOWINDOW CON CLICK
                                },
                              ),
                              quintaLuxor = Marker(
                                markerId: const MarkerId('Quinta Luxor'),
                                position: const LatLng(
                                    10.666711923974145, -71.6317473478305),
                                icon: customIcons.isNotEmpty
                                    ? customIcons[2]
                                    : BitmapDescriptor.defaultMarker,
                                onTap: () {
                                  goToLocation(const LatLng(
                                      10.666711923974145, -71.6317473478305));
                                  /* showCustomInfoWindow(context, 'Tranvía de Maracaibo', 'Sede del tranvía de Maracaibo'); */ //MUESTRA EL INFOWINDOW CON CLICK
                                },
                              ),
                            },
                            polylines: polylines,
                            /* polylines: {
                          if (info != null)
                            Polyline(
                              polylineId: const PolylineId('overview_polyline'),
                              color: Colors.blue,
                              width: 5,
                              points: info!.polylinePoints
                                  .map((e) => LatLng(e.latitude, e.longitude))
                                  .toList(),
                            ),
                        },	 */
                            style: mapStyle,
                          ),
                          if (info != null)
                            Positioned(
                              top: 20.0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                  horizontal: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellowAccent,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 2),
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${info!.totalDistance}, ${info!.totalDuration}',
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                      Positioned(
                        bottom: 120.0,
                        right: 7.0,
                        height: 45,
                        width: 45,
                        child: FloatingActionButton(
                            backgroundColor: ThemeCore.primaryColor,
                            foregroundColor: Colors.white,
                            onPressed: () {
                              goToCenter(center);
                            },
                            child: const Icon(Icons.my_location)),
                      ),
                      /* Positioned(
                    bottom: 20.0,
                    right: 140.0,
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      backgroundColor: rutaSeleccionada ? ThemeCore.primaryColor : Colors.grey,
                      foregroundColor: Colors.white,
                      onPressed: rutaSeleccionada ? () => reservaTranvia('ruta') : null,
                      child: const Icon(Icons.bookmark_border),
                    ),
                  ), */
                      Positioned(
                        bottom: 180.0,
                        right: 7.0,
                        height: 45,
                        width: 45,
                        child: FloatingActionButton(
                          backgroundColor: ThemeCore.primaryColor,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            limpiarRuta(polylines);
                          },
                          child: const Icon(Icons.clear_rounded),
                        ),
                      )
                    ],
                  )),
            ],
          ));
    });
  }
}
