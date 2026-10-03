import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/features/splash/presentation/pages/splash_screen.dart';
import 'package:camera/camera.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:frontend/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:frontend/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:frontend/features/profile/domain/usecases/profile_usecases.dart';
import 'package:frontend/features/profile/presentation/bloc/profile_bloc.dart';

import 'package:frontend/features/diagnosis/data/datasources/diagnosis_remote_data_source.dart';
import 'package:frontend/features/diagnosis/data/repositories/diagnosis_repository_impl.dart';
import 'package:frontend/features/diagnosis/domain/usecases/diagnosis_usecases.dart';
import 'package:frontend/features/diagnosis/presentation/bloc/diagnosis_bloc.dart';

import 'package:frontend/features/community/data/datasources/community_remote_data_source.dart';
import 'package:frontend/features/community/data/repositories/community_repository_impl.dart';
import 'package:frontend/features/community/domain/usecases/community_usecases.dart';
import 'package:frontend/features/community/presentation/bloc/community_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            final remoteDataSource = AuthRemoteDataSourceImpl();
            final repository = AuthRepositoryImpl(remoteDataSource);
            return AuthBloc(
              loginUseCase: LoginUseCase(repository),
              registerUseCase: RegisterUseCase(repository),
            );
          },
        ),
        BlocProvider<ProfileBloc>(
          create: (context) {
            final remoteDataSource = ProfileRemoteDataSourceImpl();
            final repository = ProfileRepositoryImpl(remoteDataSource);
            return ProfileBloc(
              fetchProfileUseCase: FetchProfileUseCase(repository),
              updateProfileUseCase: UpdateProfileUseCase(repository),
              logoutUseCase: LogoutUseCase(repository),
            );
          },
        ),
        BlocProvider<DiagnosisBloc>(
          create: (context) {
            final remoteDataSource = DiagnosisRemoteDataSourceImpl();
            final repository = DiagnosisRepositoryImpl(remoteDataSource);
            return DiagnosisBloc(
              performDiagnosisUseCase: PerformDiagnosisUseCase(repository),
              fetchHistoryUseCase: FetchHistoryUseCase(repository),
              saveDiagnosisUseCase: SaveDiagnosisUseCase(repository),
            );
          },
        ),
        BlocProvider<CommunityBloc>(
          create: (context) {
            final remoteDataSource = CommunityRemoteDataSourceImpl();
            final repository = CommunityRepositoryImpl(remoteDataSource);
            return CommunityBloc(
              getPostsUseCase: GetPostsUseCase(repository),
              searchPostsUseCase: SearchPostsUseCase(repository),
              getUserPostsUseCase: GetUserPostsUseCase(repository),
              createPostUseCase: CreatePostUseCase(repository),
              updatePostUseCase: UpdatePostUseCase(repository),
              deletePostUseCase: DeletePostUseCase(repository),
              getCommentsUseCase: GetCommentsUseCase(repository),
              addCommentUseCase: AddCommentUseCase(repository),
              updateCommentUseCase: UpdateCommentUseCase(repository),
              deleteCommentUseCase: DeleteCommentUseCase(repository),
            );
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MangoCare',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB), // Tailwind blue-600
            primary: const Color(0xFF2563EB),
            secondary: const Color(0xFF10B981), // Tailwind emerald-500
            background: const Color(0xFFF8FAFC), // Tailwind slate-50
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF1E293B), // Tailwind slate-800
          ),
        ),
        home: SplashScreen(cameras: cameras),
      ),
    );
  }
}
