import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OnboardingFlow extends StatefulWidget {
  final VoidCallback? onFinish;

  const OnboardingFlow({Key? key, this.onFinish}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late PageController _controller;
  int _page = 0;

  final List<_SlideData> _slides = const [
    _SlideData(
      title: 'Lên Kế Hoạch Chuyến Đi Dã Đoàn',
      description: 'Hợp tác với bạn bè và gia đình để định tạo lịch trình chuyến đi hoàn hảo trong một không gian làm việc chung.',
      imageUrl: 'https://images.unsplash.com/photo-1506869640319-fe1a24fd76dc?w=500&h=500&fit=crop',
      icon: Icons.people,
      color: Color(0xFF1A73E8),
    ),
    _SlideData(
      title: 'Chia Chi Phí Thông Minh',
      description: 'Theo dõi chi tiêu nhóm và chia hóa đơn tự động. Không còn những cuộc trò chuyện tế nhị về tiền bạc.',
      imageUrl: 'https://images.unsplash.com/photo-1634733988138-bf2c3a2a13fa?w=500&h=500&fit=crop',
      icon: Icons.credit_card,
      color: Color(0xFFA8E6CF),
    ),
    _SlideData(
      title: 'Lịch Trình Hợp Tác & 80 Phương',
      description: 'Gợi ý các hoạt động, bỏ phiếu cho những hoạt động yêu thích, và cùng nhau tạo lịch trình hoàn hảo.',
      imageUrl: 'https://images.unsplash.com/photo-1617106399900-61a7561d1d2f?w=500&h=500&fit=crop',
      icon: Icons.calendar_today,
      color: Color(0xFF1A73E8),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
    } else {
      widget.onFinish?.call();
    }
  }

  void _skip() {
    _controller.animateToPage(_slides.length - 1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Visibility(
                  visible: _page < _slides.length - 1,
                  child: TextButton(
                    onPressed: _skip,
                    child: const Text('Bỏ qua', style: TextStyle(color: Color(0xFF999999), fontSize: 14)),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) => _SlidePage(slide: _slides[index]),
              ),
            ),

            // Dots + button section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final active = i == _page;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: active ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? const Color(0xFF1A73E8) : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _page == _slides.length - 1 ? 'Bắt Đầu' : 'Tiếp',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final String title;
  final String description;
  final String imageUrl;
  final IconData icon;
  final Color color;

  const _SlideData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.icon,
    required this.color,
  });
}

class _SlidePage extends StatelessWidget {
  final _SlideData slide;

  const _SlidePage({Key? key, required this.slide}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Large image with rounded corners
          Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CachedNetworkImage(
                imageUrl: slide.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 64, color: Colors.grey),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Icon in colored circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: slide.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: slide.color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(slide.icon, size: 40, color: Colors.white),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

