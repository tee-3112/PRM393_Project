import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuchi/providers/app_provider.dart';
import 'package:quanlythuchi/screens/home_screen.dart';
import 'package:quanlythuchi/utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _uCtl = TextEditingController();
  final _pCtl = TextEditingController();
  final _eCtl = TextEditingController();
  final _nCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;
  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _uCtl.dispose(); _pCtl.dispose(); _eCtl.dispose(); _nCtl.dispose();
    _anim.dispose(); super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final p = context.read<AppProvider>();
    bool ok = false; String? err;
    if (_isLogin) {
      ok = await p.login(_uCtl.text.trim(), _pCtl.text);
      if (!ok) err = 'Sai tên đăng nhập hoặc mật khẩu';
    } else {
      err = await p.register(_uCtl.text.trim(), _eCtl.text.trim(), _nCtl.text.trim(), _pCtl.text);
      ok = err == null;
    }
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ?? 'Lỗi'), backgroundColor: AppTheme.expenseColor, behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: SafeArea(child: FadeTransition(opacity: _fade, child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Hero(tag: 'logo', child: Container(
              width: 76, height: 76,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))]),
              child: const Icon(Icons.account_balance_wallet_rounded, size: 40, color: AppTheme.primaryGreen),
            )),
            const SizedBox(height: 14),
            const Text('Quản lý Thu Chi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            const Text('Theo dõi tài chính cá nhân', style: TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))]),
              child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Expanded(child: GestureDetector(
                      onTap: () => setState(() => _isLogin = true),
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: _isLogin ? AppTheme.primaryGreen : null, borderRadius: BorderRadius.circular(10)),
                        child: Text('Đăng nhập', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: _isLogin ? Colors.white : AppTheme.textSecondary, fontSize: 14)),
                      ),
                    )),
                    Expanded(child: GestureDetector(
                      onTap: () => setState(() => _isLogin = false),
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: !_isLogin ? AppTheme.primaryGreen : null, borderRadius: BorderRadius.circular(10)),
                        child: Text('Đăng ký', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: !_isLogin ? Colors.white : AppTheme.textSecondary, fontSize: 14)),
                      ),
                    )),
                  ]),
                ),
                const SizedBox(height: 18),
                TextFormField(controller: _uCtl,
                  decoration: InputDecoration(labelText: 'Tên đăng nhập', prefixIcon: const Icon(Icons.person_outline, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên đăng nhập' : null,
                ),
                const SizedBox(height: 10),
                if (!_isLogin) ...[
                  TextFormField(controller: _eCtl,
                    decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                    keyboardType: TextInputType.emailAddress, validator: (v) => v == null || v.trim().isEmpty ? 'Nhập email' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(controller: _nCtl,
                    decoration: InputDecoration(labelText: 'Họ tên', prefixIcon: const Icon(Icons.person, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nhập họ tên' : null,
                  ),
                  const SizedBox(height: 10),
                ],
                TextFormField(controller: _pCtl, obscureText: _obscure,
                  decoration: InputDecoration(labelText: 'Mật khẩu', prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscure = !_obscure)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  validator: (v) => v == null || v.isEmpty ? 'Nhập mật khẩu' : null,
                ),
                const SizedBox(height: 18),
                SizedBox(height: 48, child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 1),
                  child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text(_isLogin ? 'Đăng nhập' : 'Đăng ký', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                )),
                if (_isLogin) ...[const SizedBox(height: 8), Center(child: Text('demo / 123456', style: TextStyle(fontSize: 11, color: Colors.grey[400])))],
              ])),
            ),
          ]),
        ),
      ))),
    );
  }
}