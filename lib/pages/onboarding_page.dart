import 'package:flutter/material.dart';
import 'package:onlyfunds_v1/widgets/widgets.dart';




class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/onboardimg1.png",
      "title": "Smart Student Budget",
      "description": "Easily track your income and expenses in one place"
    },
    {
      "image": "assets/images/onboardimg2.png",
      "title": "Plan Better",
      "description": "Organize your finances and reach your goals"
    },
    {
      "image": "assets/images/onboardimg3.png",
      "title": "Stay on Track",
      "description": "Get reminders and insights for better budgeting"
    }
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    resizeToAvoidBottomInset: false,
    backgroundColor: Colors.grey[100],
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
               itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return OnBoardingCard(
                      imageAsset: page['image']!,
                       title: page['title']!,
                        description: page['description']!
                      );
                    },
                  ),
                ),
                
                Padding(padding: const EdgeInsets.only(bottom: 40),
                child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                        width: _currentPage == index ? 14 : 8,
                        height: _currentPage == index ? 14 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
                child: Button(
                  text: _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                  onPressed: _nextPage,
                  backgroundColor: _currentPage == _pages.length - 1 
                      ? Colors.black 
                      : Colors.white,
                  textColor: _currentPage == _pages.length - 1 
                      ? Colors.white 
                      : Colors.black,
                  borderColor: _currentPage == _pages.length -1
                      ? Colors.black
                      : Colors.white
                ),
              ),
          ],
        ),
      ),
    );
  }
}

