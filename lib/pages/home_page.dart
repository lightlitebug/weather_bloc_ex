import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_bloc_ex/blocs/settings_bloc.dart';
import 'package:weather_bloc_ex/blocs/weather_bloc.dart';
import 'package:weather_bloc_ex/pages/search_page.dart';
import 'package:weather_bloc_ex/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  String calculateTemp(TemperatureUnit tempUnit, double temperature) {
    if (tempUnit == TemperatureUnit.fahrenheit) {
      return ((temperature * 9 / 5) + 32).toStringAsFixed(2) + '℉';
    }
    return temperature.toStringAsFixed(2) + '℃';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SettingsPage();
                }),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final String city = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SearchPage();
                }),
              );

              if (city != null) {
                BlocProvider.of<WeatherBloc>(context)
                    .add(WeatherRequested(city: city));
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<WeatherBloc, WeatherState>(
        listener: (context, state) {
          if (state is WeatherLoadedSuccess) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
          }
        },
        builder: (context, state) {
          if (state is WeatherInitial) {
            return Center(
              child: Text(
                'Select a city',
                style: TextStyle(fontSize: 18.0),
              ),
            );
          }
          if (state is WeatherLoadedInProgress) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is WeatherLoadedSuccess) {
            return RefreshIndicator(
              onRefresh: () {
                BlocProvider.of<WeatherBloc>(context)
                    .add(WeatherRefreshRequested(city: state.weather.city));
                return _refreshCompleter.future;
              },
              child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, settings) {
                  return ListView(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.height / 6),
                      Text(
                        state.weather.city,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        '${TimeOfDay.fromDateTime(state.weather.lastUpdated).format(context)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(height: 60.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            calculateTemp(settings.temperatureUnit,
                                state.weather.theTemp),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Max:' +
                                    calculateTemp(settings.temperatureUnit,
                                        state.weather.maxTemp),
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Text(
                                'Min:' +
                                    calculateTemp(settings.temperatureUnit,
                                        state.weather.minTemp),
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        '${state.weather.weatherStateName}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 32),
                      ),
                    ],
                  );
                },
              ),
            );
          }

          return Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}
