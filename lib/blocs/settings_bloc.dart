// events
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

abstract class SettingsEvent extends Equatable {}

class SettingsToggled extends SettingsEvent {
  @override
  List<Object> get props => [];
}

// states
enum TemperatureUnit { celcius, fahrenheit }

class SettingsState extends Equatable {
  final TemperatureUnit temperatureUnit;

  SettingsState({@required this.temperatureUnit})
      : assert(temperatureUnit != null);

  @override
  List<Object> get props => [temperatureUnit];
}

// bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc()
      : super(
          SettingsState(temperatureUnit: TemperatureUnit.celcius),
        );

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is SettingsToggled) {
      yield SettingsState(
        temperatureUnit: state.temperatureUnit == TemperatureUnit.celcius
            ? TemperatureUnit.fahrenheit
            : TemperatureUnit.celcius,
      );
    }
  }
}
