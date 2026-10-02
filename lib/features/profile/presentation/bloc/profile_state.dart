import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profileData;
  const ProfileLoaded(this.profileData);
  @override
  List<Object?> get props => [profileData];
}

class ProfileUpdateSuccess extends ProfileState {
  final Map<String, dynamic> profileData;
  const ProfileUpdateSuccess(this.profileData);
  @override
  List<Object?> get props => [profileData];
}

class ProfileLogoutSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
