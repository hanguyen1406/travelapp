import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/viewModel/auth_view_model.dart';
import 'package:travelapp/view/trip/HomeScreen.dart';
import 'SignupScreen.dart';

class LoginScreen extends StatefulWidget {
	const LoginScreen({Key? key}) : super(key: key);

	@override
	State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
	final _usernameController = TextEditingController();
	final _passwordController = TextEditingController();
	bool _obscurePassword = true;

	@override
	void initState() {
		super.initState();
		// Listen to auth state changes
		WidgetsBinding.instance.addPostFrameCallback((_) {
			final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
			authViewModel.addListener(_onAuthStateChanged);
		});
	}

	void _onAuthStateChanged() {
		final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
		if (authViewModel.isLoggedIn()) {
			// Navigate to HomeScreen and remove login screen from stack
			Navigator.of(context).pushReplacement(
				MaterialPageRoute(builder: (context) => const HomeScreen()),
			);
		}
	}

	@override
	void dispose() {
		_usernameController.dispose();
		_passwordController.dispose();
		final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
		authViewModel.removeListener(_onAuthStateChanged);
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final size = MediaQuery.of(context).size;

		return Scaffold(
			backgroundColor: Colors.white,
			body: SafeArea(
				child: Center(
					child: SingleChildScrollView(
						padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
						child: ConstrainedBox(
							constraints: BoxConstraints(maxWidth: 460),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									Container(
										padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
										decoration: BoxDecoration(
											color: Colors.white,
											borderRadius: BorderRadius.circular(24),
											boxShadow: [
												BoxShadow(
													color: Colors.black.withOpacity(0.06),
													blurRadius: 20,
													offset: const Offset(0, 8),
												),
											],
										),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												// Top icon
												Row(
													children: [
														Container(
															width: 48,
															height: 48,
															decoration: BoxDecoration(
																color: const Color(0xFF1E90FF),
																borderRadius: BorderRadius.circular(12),
																boxShadow: [
																	BoxShadow(
																		color: Colors.blue.withOpacity(0.12),
																		blurRadius: 8,
																		offset: const Offset(0, 4),
																	),
																],
															),
															child: const Center(
																child: Icon(
																	Icons.flight_takeoff,
																	color: Colors.white,
																),
															),
														),
													],
												),

												const SizedBox(height: 18),

												// Greeting
												const Text(
													'Xin chào!',
													style: TextStyle(
														fontSize: 20,
														fontWeight: FontWeight.w700,
													),
												),

												const SizedBox(height: 6),

												const Text(
													'Đăng nhập để lên kế hoạch cho chuyến đi của bạn',
													style: TextStyle(
														fontSize: 13,
														color: Colors.black54,
													),
												),

												const SizedBox(height: 22),

												// Username field
												TextField(
													controller: _usernameController,
													keyboardType: TextInputType.text,
													decoration: InputDecoration(
														labelText: 'Username',
														hintText: 'your.username',
														prefixIcon: const Icon(Icons.person_outline),
														filled: true,
														fillColor: const Color(0xFFF6F8FB),
														border: OutlineInputBorder(
															borderSide: BorderSide.none,
															borderRadius: BorderRadius.circular(12),
														),
													),
												),

												const SizedBox(height: 14),

												// Password field
												TextField(
													controller: _passwordController,
													obscureText: _obscurePassword,
													decoration: InputDecoration(
														labelText: 'Password',
														hintText: 'Enter your password',
														prefixIcon: const Icon(Icons.lock_outline),
														filled: true,
														fillColor: const Color(0xFFF6F8FB),
														border: OutlineInputBorder(
															borderSide: BorderSide.none,
															borderRadius: BorderRadius.circular(12),
														),
														suffixIcon: IconButton(
															icon: Icon(
																_obscurePassword ? Icons.visibility_off : Icons.visibility,
																color: Colors.black45,
															),
															onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
														),
													),
												),

												const SizedBox(height: 8),

												Align(
													alignment: Alignment.centerRight,
													child: TextButton(
														onPressed: () {},
														style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(44, 28), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
														child: const Text(
															'Quên mật khẩu?',
															style: TextStyle(color: Color(0xFF1E90FF)),
														),
													),
												),

												const SizedBox(height: 6),

												// Login button
												Consumer<AuthViewModel>(
													builder: (context, authViewModel, _) {
														return SizedBox(
															width: double.infinity,
															child: ElevatedButton(
																onPressed: authViewModel.isLoading
																	? null
																	: () => _handleLogin(context, authViewModel),
																style: ElevatedButton.styleFrom(
																	backgroundColor: const Color(0xFF1E90FF),
																	padding: const EdgeInsets.symmetric(vertical: 14),
																	shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
																	elevation: 2,
																),
																child: authViewModel.isLoading
																	? const SizedBox(
																		height: 20,
																		width: 20,
																		child: CircularProgressIndicator(
																			strokeWidth: 2,
																			valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
																		),
																	)
																	: const Text(
																		'Đăng nhập',
																		style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
																	),
															),
														);
													},
												),
												
												// Error message
												Consumer<AuthViewModel>(
													builder: (context, authViewModel, _) {
														if (authViewModel.errorMessage != null) {
															return Padding(
																padding: const EdgeInsets.only(top: 12),
																child: Container(
																	padding: const EdgeInsets.all(12),
																	decoration: BoxDecoration(
																		color: Colors.red.withOpacity(0.1),
																		borderRadius: BorderRadius.circular(8),
																		border: Border.all(color: Colors.red.withOpacity(0.3)),
																	),
																	child: Text(
																		authViewModel.errorMessage!,
																		style: const TextStyle(
																			color: Colors.red,
																			fontSize: 12,
																		),
																	),
																),
															);
														}
														return const SizedBox.shrink();
													},
												),

												const SizedBox(height: 14),

												Center(
													child: Row(
														mainAxisSize: MainAxisSize.min,
														children: [
															const Text('Chưa có tài khoản? ', style: TextStyle(color: Colors.black54)),
															TextButton(
																onPressed: () {
																	Navigator.of(context).push(
																		MaterialPageRoute(builder: (context) => const SignupScreen()),
																	);
																},
																style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(44, 28), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
																child: const Text('Đăng ký', style: TextStyle(color: Color(0xFF1E90FF))),
															),
														],
													),
												),
											],
										),
									),

									// Add some spacing at bottom to match mock
									SizedBox(height: size.height * 0.04),
								],
							),
						),
					),
				),
			),
		);
	}

	void _handleLogin(BuildContext context, AuthViewModel authViewModel) {
		if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Vui lòng điền đầy đủ thông tin đăng nhập'),
					backgroundColor: Colors.red,
				),
			);
			return;
		}

		// Call login - navigation will happen via listener
		authViewModel.login(
			_usernameController.text,
			_passwordController.text,
		);
	}}