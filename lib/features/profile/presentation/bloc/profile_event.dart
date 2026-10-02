import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileFetchRequested extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final String nama;
  final String username;
  final String? password;
  const ProfileUpdateRequested({required this.nama, required this.username, this.password});
  @override
  List<Object?> get props => [nama, username, password];
}

class ProfileLogoutRequested extends ProfileEvent {}
