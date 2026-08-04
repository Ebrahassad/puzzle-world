import 'package:flutter/material.dart';
import 'wallet_screen.dart';

class walletIconWidget extends StatefulWidget {
const walletIconWidget({super.key});

@override
State<walletIconWidget> createState() => _WalletIconWidgetState();
}

class _WalletIconWidgetState extends State<walletIconWidget>
with SingleTickerProviderStateMixin {
late AnimationController _animationController;
bool _isClicked = false;

@override
void initState() {
super.initState();
_animationController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 600),
)..repeat(reverse: true);
}

@override
void dispose() {
_animationController.dispose();
super.dispose();
}

void _openWalletScreen(BuildContext context) async {
setState(() {
_isClicked = true;
});
_animationController.stop();

await Navigator.push(  
  context,  
  MaterialPageRoute(builder: (context) => const WalletScreen()),  
);  

if (mounted) {  
  setState(() {  
    _isClicked = false;  
  });  
  _animationController.repeat(reverse: true);  
}

}

@override
Widget build(BuildContext context) {
return Positioned(
top: 40,
right: 20,
child: GestureDetector(
onTap: () => _openWalletScreen(context),
child: AnimatedBuilder(
animation: _animationController,
builder: (context, child) {
double angle = _isClicked ? 0.0 : (_animationController.value * 0.15 - 0.075);

return Transform.rotate(  
          angle: angle,  
          child: Image.asset(  
            _isClicked   
                ? "assets/images/ui/open_wallet.png"   
                : "assets/images/ui/close_wallet.png",  
            width: 60,  
            height: 60,  
            fit: BoxFit.contain,  
            errorBuilder: (_, __, ___) => const Icon(  
              Icons.account_balance_wallet,  
              size: 50,  
              color: Colors.amber,  
            ),  
          ),  
        );  
      },  
    ),  
  ),  
);

}
}