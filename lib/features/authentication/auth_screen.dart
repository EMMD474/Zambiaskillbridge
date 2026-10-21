import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthState();
}

class _AuthState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _id = TextEditingController();
  final _pass = TextEditingController();
  bool _register = true;
  bool _show = false;
  bool _terms = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _id, _pass]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    setState(() => _error = null);
    if (!_form.currentState!.validate()) return;
    if (_register && !_terms) {
      setState(() => _error = 'Please accept the terms and privacy notice to continue.');
      return;
    }
    final ctl = ref.read(appProvider.notifier);
    if (_register) {
      final digits = normaliseZmPhone(_phone.text)!;
      final err = ctl.register(name: _name.text, phone: '+260$digits', email: _email.text);
      if (err != null) {
        setState(() => _error = err);
        return;
      }
      context.go(ref.read(appProvider).role == UserRole.worker ? '/setup' : '/home');
    } else {
      final err = ctl.signIn(_id.text);
      if (err != null) {
        setState(() => _error = err);
        return;
      }
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(appProvider.select((s) => s.chosenRole)) ?? UserRole.client;
    final auth = ref.read(authRepoProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + MediaQuery.of(context).viewInsets.bottom),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _form,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Align(alignment: Alignment.centerLeft, child: SbLogo(size: 40)),
                  const SizedBox(height: 22),
                  Text(_register ? 'Create your account' : 'Welcome back', style: SB.h1),
                  const SizedBox(height: 4),
                  Text(role == UserRole.worker ? 'Signing up as a skilled worker' : 'Signing up as a client', style: const TextStyle(color: SB.text2)),
                  const SizedBox(height: 14),
                  const InfoNote('Demo sign in. Your details stay on this phone. No password is stored or sent anywhere, and there is no server behind this prototype.'),
                  const SizedBox(height: 16),
                  if (_register) ...[
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your full name.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]'))],
                      decoration: const InputDecoration(labelText: 'Phone number', prefixText: '+260  ', hintText: '97 123 4567'),
                      validator: (v) => normaliseZmPhone(v ?? '') == null ? 'Enter a valid Zambian mobile number, for example 97 123 4567.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Email (optional)'),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return null;
                        return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t) ? null : 'Enter a valid email address.';
                      },
                    ),
                  ] else
                    TextFormField(
                      controller: _id,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Phone number or email'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter the phone number or email you signed up with.' : null,
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pass,
                    obscureText: !_show,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        tooltip: _show ? 'Hide password' : 'Show password',
                        icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _show = !_show),
                      ),
                    ),
                    validator: (v) => auth.validatePassword(v ?? ''),
                  ),
                  if (_register)
                    CheckboxListTile(
                      value: _terms,
                      onChanged: (v) => setState(() => _terms = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('I accept the terms and privacy notice for this demo.', style: TextStyle(fontSize: 13)),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: InfoNote(_error!, icon: Icons.error_outline, color: SB.error),
                    ),
                  const SizedBox(height: 16),
                  PrimaryButton(_register ? 'Create account' : 'Sign in', onPressed: _submit),
                  TextButton(
                    onPressed: () => setState(() {
                      _register = !_register;
                      _error = null;
                    }),
                    child: Text(_register ? 'Already have an account? Sign in' : 'New here? Create an account'),
                  ),
                  const Divider(height: 28),
                  SecondaryButton('Continue as demo', icon: Icons.play_circle_outline, onPressed: () {
                    ref.read(appProvider.notifier).continueAsDemo(role);
                    context.go('/home');
                  }),
                  const SizedBox(height: 6),
                  const Text('Explore with fictional sample data. No account needed.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: SB.text2)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
