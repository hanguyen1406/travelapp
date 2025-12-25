import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/viewModel/auth_view_model.dart';
import 'LoginScreen.dart';

class SignupScreen extends StatefulWidget {
	const SignupScreen({Key? key}) : super(key: key);

	@override
	State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
	final _nameController = TextEditingController();
	final _surnameController = TextEditingController();
	final _usernameController = TextEditingController();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();
	final _phoneController = TextEditingController();
	bool _obscurePassword = true;

	@override
	void dispose() {
		_nameController.dispose();
		_surnameController.dispose();
		_usernameController.dispose();
		_emailController.dispose();
		_passwordController.dispose();
		_phoneController.dispose();
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
						padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
						child: ConstrainedBox(
							constraints: const BoxConstraints(maxWidth: 460),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									// Back label
									Align(
										alignment: Alignment.centerLeft,
										child: TextButton.icon(
											onPressed: () => Navigator.of(context).maybePop(),
											icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black54),
											label: const Text('Quay lại', style: TextStyle(color: Colors.black54)),
											style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(36, 36), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
										),
									),

									Container(
										padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
										decoration: BoxDecoration(
											color: Colors.white,
											borderRadius: BorderRadius.circular(24),
											boxShadow: [
												BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
											],
										),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												// small avatar icon
												Center(
													child: Container(
														width: 56,
														height: 56,
														decoration: BoxDecoration(
															color: const Color(0xFFE6F7F1),
															borderRadius: BorderRadius.circular(12),
														),
														child: const Center(child: Icon(Icons.language, color: Color(0xFF2E8B57))),
													),
												),

												const SizedBox(height: 16),

												const Text(
													'Tạo tài khoản',
													style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
												),

												const SizedBox(height: 8),

												const Text(
													'Hãy tham gia cùng chúng tôi và bắt đầu lên kế hoạch cho những chuyến đi tuyệt vời nhé!',
													style: TextStyle(fontSize: 13, color: Colors.black54),
												),

												const SizedBox(height: 18),

												const Text('Full Name', style: TextStyle(fontSize: 13, color: Colors.black87)),
												const SizedBox(height: 6),
												TextField(
													controller: _nameController,
													decoration: InputDecoration(
														hintText: 'John',
														prefixIcon: const Icon(Icons.person_outline),
														filled: true,
														fillColor: const Color(0xFFF6F8FB),
														border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
													),
												),

												const SizedBox(height: 12),

												const Text('Surname', style: TextStyle(fontSize: 13, color: Colors.black87)),
												const SizedBox(height: 6),
												TextField(
													controller: _surnameController,
													decoration: InputDecoration(
														hintText: 'Doe',
														prefixIcon: const Icon(Icons.person_outline),
														filled: true,
														fillColor: const Color(0xFFF6F8FB),
														border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
													),
												),

												const SizedBox(height: 12),

												const Text('Username', style: TextStyle(fontSize: 13, color: Colors.black87)),
												const SizedBox(height: 6),
												TextField(
													controller: _usernameController,
													decoration: InputDecoration(
														hintText: 'johndoe',
														prefixIcon: const Icon(Icons.alternate_email),
														filled: true,
														fillColor: const Color(0xFFF6F8FB),
														border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
													),
												),

												const SizedBox(height: 12),

												const Text('Email', style: TextStyle(fontSize: 13, color: Colors.black87)),
												const SizedBox(height: 6),
												TextField(
													controller: _emailController,
													keyboardType: TextInputType.emailAddress,
													decoration: InputDecoration(
														hintText: 'your.email@example.com',
														prefixIcon: const Icon(Icons.email_outlined),
														filled: true,
														fillColor: const Color(0xFFF6F8FB),
														border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
													),
												),

												const SizedBox(height: 12),

												const Text('Phone', style: TextStyle(fontSize: 13, color: Colors.black87)),
												const SizedBox(height: 6),
												TextField(
													controller: _phoneController,
													keyboardType: TextInputType.phone,
													decoration: InputDecoration(
														hintText: '+84 123 456 789',
														prefixIcon: const Icon(Icons.phone_outlined),
														filled: true,
														fillColor: const Color(0xFFF6F8FB),
														border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
													),
												),

												const SizedBox(height: 12),

												const Text('Password', style: TextStyle(fontSize: 13, color: Colors.black87)),
												const SizedBox(height: 6),
												TextField(
													controller: _passwordController,
													obscureText: _obscurePassword,
													decoration: InputDecoration(
														hintText: 'Create a strong password',
														prefixIcon: const Icon(Icons.lock_outline),
														filled: true,
														fillColor: const Color(0xFFF6F8FB),
														border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
														suffixIcon: IconButton(
															icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black45),
															onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
														),
													),
												),

												const SizedBox(height: 8),
												const Text('Phải có ít nhất 8 ký tự.', style: TextStyle(fontSize: 12, color: Colors.black54)),

												const SizedBox(height: 14),

												// Agreement text
												RichText(
													text: TextSpan(
														text: 'Tôi đồng ý với ',
														style: const TextStyle(color: Colors.black54, fontSize: 13),
														children: [
															TextSpan(
																text: 'Điều khoản',
																style: const TextStyle(color: Color(0xFF1E90FF)),
																recognizer: TapGestureRecognizer()..onTap = () {},
															),
															const TextSpan(text: ' và '),
															TextSpan(
																text: 'Chính sách',
																style: const TextStyle(color: Color(0xFF1E90FF)),
																recognizer: TapGestureRecognizer()..onTap = () {},
															),
														],
													),
												),

												const SizedBox(height: 18),

												// Signup button
												Consumer<AuthViewModel>(
													builder: (context, authViewModel, _) {
														return SizedBox(
															width: double.infinity,
															child: ElevatedButton(
																onPressed: authViewModel.isLoading
																	? null
																	: () => _handleSignup(context, authViewModel),
																style: ElevatedButton.styleFrom(
																	backgroundColor: const Color(0xFF1E90FF),
																	padding: const EdgeInsets.symmetric(vertical: 14),
																	shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
																	: const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

												const SizedBox(height: 16),

												// Back to login link
												Center(
													child: Row(
														mainAxisSize: MainAxisSize.min,
														children: [
															const Text('Đã có tài khoản? ', style: TextStyle(color: Colors.black54)),
															TextButton(
																onPressed: () {
																	Navigator.of(context).pop();
																},
																style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(44, 28), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
																child: const Text('Đăng nhập', style: TextStyle(color: Color(0xFF1E90FF))),
															),
														],
													),
												),
											],
										),
									),

									SizedBox(height: size.height * 0.04),
								],
							),
						),
					),
				),
			),
		);
	}

	void _handleSignup(BuildContext context, AuthViewModel authViewModel) {
		if (_nameController.text.isEmpty ||
			_surnameController.text.isEmpty ||
			_usernameController.text.isEmpty ||
			_emailController.text.isEmpty ||
			_passwordController.text.isEmpty ||
			_phoneController.text.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Vui lòng điền đầy đủ thông tin'),
					backgroundColor: Colors.red,
				),
			);
			return;
		}

		if (_passwordController.text.length < 8) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Mật khẩu phải có ít nhất 8 ký tự'),
					backgroundColor: Colors.red,
				),
			);
			return;
		}

		authViewModel.signup(
			_nameController.text,
			_surnameController.text,
			_usernameController.text,
			_emailController.text,
			_passwordController.text,
			_phoneController.text,
		).then((success) {
			if (success && mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
						backgroundColor: Colors.green,
					),
				);
				Navigator.of(context).pushReplacement(
					MaterialPageRoute(builder: (context) => const LoginScreen()),
				);
			}
		});
	}}