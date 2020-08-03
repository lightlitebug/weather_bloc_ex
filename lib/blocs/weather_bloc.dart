import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:weather_bloc_ex/models/weather.dart';
import 'package:weather_bloc_ex/repositories/weather_repository.dart';

@immutable
abstract class WeatherEvent extends Equatable {}

class WeatherRequested extends WeatherEvent {
  final String city;

  WeatherRequested({@required this.city}) : assert(city != null);

  @override
  List<Object> get props => [city];
}

class WeatherRefreshRequested extends WeatherEvent {
  final String city;

  WeatherRefreshRequested({@required this.city}) : assert(city != null);

  @override
  List<Object> get props => [city];
}

// weather state
@immutable
abstract class WeatherState extends Equatable {
  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoadedInProgress extends WeatherState {}

class WeatherLoadedSuccess extends WeatherState {
  final Weather weather;

  WeatherLoadedSuccess({@required this.weather}) : assert(weather != null);

  @override
  List<Object> get props => [weather];
}

class WeatherLoadedFailure extends WeatherState {}

// mapEventToState
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({this.weatherRepository})
      : assert(weatherRepository != null),
        super(WeatherInitial());

  @override
  Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
    if (event is WeatherRequested) {
      yield WeatherLoadedInProgress();

      try {
        final Weather weather = await weatherRepository.getWeather(event.city);
        yield WeatherLoadedSuccess(weather: weather);
      } catch (_) {
        yield WeatherLoadedFailure();
      }
    }

    if (event is WeatherRefreshRequested) {
      try {
        final Weather weather = await weatherRepository.getWeather(event.city);
        yield WeatherLoadedSuccess(weather: weather);
      } catch (_) {
        yield WeatherLoadedFailure();
      }
    }
  }
}
