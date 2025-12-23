import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
	const SignupScreen({Key? key}) : super(key: key);

	@override
	State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
	final _nameController = TextEditingController();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();
	bool _obscurePassword = true;

	@override
	void dispose() {
		_nameController.dispose();
		_emailController.dispose();
		_passwordController.dispose();
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
														hintText: 'John Doe',
														prefixIcon: const Icon(Icons.person_outline),
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

												SizedBox(
													width: double.infinity,
													child: ElevatedButton(
														onPressed: () {},
														style: ElevatedButton.styleFrom(
															backgroundColor: const Color(0xFF1E90FF),
															padding: const EdgeInsets.symmetric(vertical: 14),
															shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
														),
														child: const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
}

