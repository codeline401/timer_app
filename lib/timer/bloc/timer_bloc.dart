import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart'; //fournit des outils pour comparer des objets de manières équitable
import 'package:flutter_timer/ticker.dart';
//import 'package:flutter/rendering.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> { //TimerEvent événements liés à la minuterie, TimerState états de la minutérie
  //define the initial state of our TimerBloc
  static const int _duration = 60; //durée initiale de la minuterie

  final Ticker _ticker;

  StreamSubscription<int>? _tickerSubscription; //un abonnement à un flux (Stream) d'entiers
  //pour suivre le défilement du temps

  TimerBloc({required Ticker ticker}) : _ticker = ticker, super(TimerInitial(_duration)){
    on<TimerStarted>(_onStarted);
    on<_TimerTicked>(_onTicker);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
  }

  @override
  Future<void> close(){
    _tickerSubscription?.cancel();
    return super.close();
  }

  //méthode appellé lorsqu'un Evenement TimerStarted est déclenché
  void _onStarted(TimerStarted event, Emitter<TimerState> emit){
    //emettre un nouvel état TimerRunInProgress avec la durée de la minuterie.
    emit(TimerRunInProgress(event.duration));

    //ensuite annulle tout abonnement précedent et crée un nouvel abonnement à la minuterie emettant un événement _TimerTicked à chaque tic
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
      .tick(ticks: event.duration)
      .listen((duration) => add(_TimerTicked(duration: duration)));
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit){
    if(state is TimerRunInProgress){
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit){
    //if the timerBloc has a state TimerRunPause and it receives TimerResumed event,
    //then it resume the _tickerSubscription and pushes a TimerRunInProgress state with 
    //the current duration
    if(state is TimerRunPause){
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    //in any state of the TimerBloc, the reset event will cancel the _tickerSubscrtion and
    //pushes the timer to initial state with the initial duration
    _tickerSubscription?.cancel();
    emit(const TimerInitial(_duration));
  }

  void _onTicker(_TimerTicked event, Emitter<TimerState> emit){
    emit(
      event.duration > 0 
        ? TimerRunInProgress(event.duration)
        : TimerRunComplete(),
    );
  }
}
