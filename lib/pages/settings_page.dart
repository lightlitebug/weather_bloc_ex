import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_bloc_ex/blocs/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 10,
              top: 20,
              right: 10,
            ),
            child: ListTile(
              title: Text(
                'Temperature Units',
              ),
              isThreeLine: true,
              subtitle: Text('Celcius or Farenheight\nDefault: Celcius'),
              trailing: Switch(
                value: state.temperatureUnit == TemperatureUnit.celcius,
                onChanged: (_) {
                  BlocProvider.of<SettingsBloc>(context).add(SettingsToggled());
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
