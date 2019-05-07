import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String initialText, finalText;
  final ButtonStyle buttonStyle;
  final IconData iconData;
  final double iconSize;
  final Duration animationDuration;
  final Function onTap;

  AnimatedButton(
      {this.initialText,
      this.finalText,
      this.buttonStyle,
      this.iconData,
      this.iconSize,
      this.animationDuration,
      this.onTap});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  AnimationController _controller;
  ButtonState _currentState;
  Duration _smallDuration;
  Animation<double> _scaleFinalTextAnimation;

  final animationCurve = Curves.fastOutSlowIn;

  @override
  void initState() {
    super.initState();
    _currentState = ButtonState.SHOW_ONLY_TEXT;
    _smallDuration = Duration(
        milliseconds: (widget.animationDuration.inMilliseconds * 0.5).round());
    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _controller.addListener(() {
      double _controllerValue = _controller.value;
      if (_controllerValue < 0.2) {
        setState(() {
          _currentState = ButtonState.SHOW_ONLY_ICON;
        });
      } else if (_controllerValue > 0.5) {
        setState(() {
          _currentState = ButtonState.SHOW_TEXT_ICON;
        });
      }
    });
    _controller.addStatusListener((currentStatus) {
      switch (currentStatus) {
        case AnimationStatus.completed:
          widget.onTap();
          break;
        case AnimationStatus.dismissed:
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
      }
    });
    _scaleFinalTextAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius:
          BorderRadius.all(Radius.circular(widget.buttonStyle.borderRadius)),
      elevation: widget.buttonStyle.elevation,
      child: InkWell(
        onTap: () {
          _controller.forward();
        },
        child: AnimatedContainer(
          curve: animationCurve,
//          duration: widget.animationDuration,
          duration: _smallDuration,
          height: widget.iconSize + 16,
          decoration: BoxDecoration(
              border: Border.all(
                  color: (_currentState == ButtonState.SHOW_ONLY_ICON ||
                          _currentState == ButtonState.SHOW_TEXT_ICON)
                      ? widget.buttonStyle.primaryColor
                      : Colors.transparent),
              color: (_currentState == ButtonState.SHOW_ONLY_ICON ||
                      _currentState == ButtonState.SHOW_TEXT_ICON)
                  ? widget.buttonStyle.secondaryColor
                  : widget.buttonStyle.primaryColor,
              borderRadius: BorderRadius.all(
                  Radius.circular(widget.buttonStyle.borderRadius))),
          padding: EdgeInsets.symmetric(
              horizontal: (_currentState == ButtonState.SHOW_ONLY_ICON ||
                      _currentState == ButtonState.SHOW_TEXT_ICON)
                  ? 16.0
                  : 48.0,
              vertical: 8.0),
          child: AnimatedSize(
            curve: animationCurve,
            vsync: this,
            duration: _smallDuration,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                (_currentState == ButtonState.SHOW_ONLY_ICON ||
                        _currentState == ButtonState.SHOW_TEXT_ICON)
                    ? Icon(
                        widget.iconData,
                        size: widget.iconSize,
                        color: widget.buttonStyle.primaryColor,
                      )
                    : Container(),
                SizedBox(
                  width:
                      _currentState == ButtonState.SHOW_TEXT_ICON ? 20.0 : 0.0,
                ),
                getTextWidget()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getTextWidget() {
    switch (_currentState) {
      case ButtonState.SHOW_ONLY_TEXT:
        return Text(
          widget.initialText,
          style: widget.buttonStyle.initialTextStyle,
        );
      case ButtonState.SHOW_ONLY_ICON:
        return Container();
      case ButtonState.SHOW_TEXT_ICON:
        return ScaleTransition(
            scale: _scaleFinalTextAnimation,
            child: Text(
              widget.finalText,
              style: widget.buttonStyle.finalTextStyle,
            ));
    }
    return Container();
  }
}

class ButtonStyle {
  final TextStyle initialTextStyle, finalTextStyle;
  final Color primaryColor, secondaryColor;
  final double elevation, borderRadius;

  ButtonStyle(
      {this.initialTextStyle,
      this.finalTextStyle,
      this.primaryColor,
      this.secondaryColor,
      this.elevation,
      this.borderRadius});
}

enum ButtonState { SHOW_ONLY_TEXT, SHOW_ONLY_ICON, SHOW_TEXT_ICON }
