import 'package:flutter/material.dart';
import '../styles/colors.dart';

class phoneField extends StatefulWidget {
  final bool fadephone;
  final TextEditingController phoneController;
  const phoneField(
      {super.key, required this.phoneController, required this.fadephone});

  @override
  State<phoneField> createState() => _phoneFieldState();
}

class _phoneFieldState extends State<phoneField>
    with SingleTickerProviderStateMixin {
  double bottomAnimationValue = 0;
  double opacityAnimationValue = 0;
  EdgeInsets paddingAnimationValue = EdgeInsets.only(top: 22);

  late TextEditingController phoneController;
  late AnimationController _animationController;
  late Animation<Color?> _animation;

  FocusNode node = FocusNode();
  @override
  void initState() {
    phoneController = widget.phoneController;
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    final tween = ColorTween(begin: Colors.grey.withOpacity(0), end: blueColor);

    _animation = tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();

    node.addListener(() {
      if (node.hasFocus) {
        setState(() {
          bottomAnimationValue = 1;
        });
      } else {
        setState(() {
          bottomAnimationValue = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0, end: widget.fadephone ? 0 : 1),
          builder: ((_, value, __) => Opacity(
                opacity: value,
                child: TextFormField(
                  controller: phoneController,
                  focusNode: node,
                  decoration: const InputDecoration(hintText: "phone"),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      if (isValidphone(value)) {
                        setState(() {
                          bottomAnimationValue = 0;
                          opacityAnimationValue = 1;
                          paddingAnimationValue = const EdgeInsets.only(top: 0);
                        });
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                        setState(() {
                          bottomAnimationValue = 1;
                          opacityAnimationValue = 0;
                          paddingAnimationValue =
                              const EdgeInsets.only(top: 22);
                        });
                      }
                    } else {
                      setState(() {
                        bottomAnimationValue = 0;
                      });
                    }
                  },
                ),
              )),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: widget.fadephone ? 0 : 300,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: bottomAnimationValue),
                curve: Curves.easeIn,
                duration: const Duration(milliseconds: 500),
                builder: ((context, value, child) => LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey.withOpacity(0.5),
                      color: Colors.black,
                    )),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedPadding(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 500),
            padding: paddingAnimationValue,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: widget.fadephone ? 0 : 1),
              duration: const Duration(milliseconds: 700),
              builder: ((context, value, child) => Opacity(
                    opacity: value,
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0)
                            .copyWith(bottom: 0),
                        child: Icon(Icons.check_rounded,
                            size: 27, color: _animation.value),
                      ),
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }

  bool isValidphone(String phone) {
    return phone.length >= 10;
  }
}
