
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'agora_state.dart';

class AgoraCubit extends Cubit<AgoraState> {
  AgoraCubit() : super(AgoraInitial());
}
