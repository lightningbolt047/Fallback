import 'package:fallback/const.dart';
import 'package:fallback/main_layout.dart';
import 'package:fallback/services/legal.dart';
import 'package:fallback/widgets_basic/buttons/custom_material_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> with SingleTickerProviderStateMixin{

  late final TabController _tabController;

  @override
  void initState() {
    _tabController=TabController(length: 1, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: TabBarView(
        controller: _tabController,
        children: [
          WelcomeScreen(proceedAction: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const MainLayout()));
          },),
        ]),
    );
  }

}




class WelcomeScreen extends StatefulWidget {
  final VoidCallback proceedAction;
  const WelcomeScreen({Key? key,required this.proceedAction}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState(proceedAction);
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {

  final VoidCallback proceedAction;

  _WelcomeScreenState(this.proceedAction);

  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final Animation<Offset> _fallbackImageOffsetAnimation;
  late final Animation<Offset> _bodyOffsetAnimation;


  @override
  void initState() {
    _animationController=AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation=Tween<double>(
        begin: 0,
        end: 1
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _fallbackImageOffsetAnimation=Tween<Offset>(
      begin: const Offset(0,-1),
      end: const Offset(0,0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _bodyOffsetAnimation=Tween<Offset>(
      begin: const Offset(0,1),
      end: const Offset(0,0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();

    super.initState();
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScaleTransition(
        scale: _animation,
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SlideTransition(
                position: _fallbackImageOffsetAnimation,
                child: Align(
                  alignment: Alignment.center,
                  child: SvgPicture.asset("assets/fallback_squircle.svg",),
                ),
              ),
              SlideTransition(
                position: _bodyOffsetAnimation,
                child: Column(
                  children: const [
                    Text("Fallback",style: TextStyle(
                        color: kIconColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w600
                    ),),
                    SizedBox(
                      height: 8,
                    ),
                    Text("Store your backup keys safely",style: TextStyle(
                        color: kIconColor,
                    ),),
                  ],
                ),
              ),
              CustomMaterialButton(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("Proceed",style: TextStyle(
                            color: kBackgroundColor,
                            fontSize: 16
                          ),
                        ),
                        SizedBox(width: 4,),
                        Icon(Icons.keyboard_arrow_right_rounded, color: kBackgroundColor,),
                      ],
                    )
                ),
                buttonColor: kIconColor,
                onPressed: (){
                  proceedAction();
                },
              ),
              InkWell(
                onTap: (){
                  showAppAboutDialog(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("By using this application, you agree to the conditions",style: TextStyle(
                    color: kIconColor,
                    fontSize: 12,
                    decoration: TextDecoration.underline
                  ),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


