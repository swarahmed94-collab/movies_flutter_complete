import '../../../../core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../settings/presentation/widgets/language_switcher.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState()=>_LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _form=GlobalKey<FormState>();
  final _email=TextEditingController();
  final _password=TextEditingController();
  bool _obscure=true;
  bool _navigated=false;
  @override
  void dispose(){_email.dispose();_password.dispose();super.dispose();}
  Future<void> _submit() async {
    if(!(_form.currentState?.validate()??false))return;
    await context.read<AuthCubit>().login(_email.text,_password.text);
  }
  @override
  Widget build(BuildContext context)=>BlocListener<AuthCubit,AuthState>(
    listener:(context,state){
      if(state.status==AuthStatus.signedIn && !_navigated &&
          (ModalRoute.of(context)?.isCurrent ?? false)){
        _navigated=true;
        Navigator.pushNamedAndRemoveUntil(context,AppRouter.shell,(_)=>false);
      } else if(state.status==AuthStatus.failed && state.failure!=null){
        showAppError(context,state.failure!.message);
      }
    },child:Scaffold(body:SafeArea(child:SingleChildScrollView(
      keyboardDismissBehavior:ScrollViewKeyboardDismissBehavior.onDrag,
      child:Padding(padding:EdgeInsets.symmetric(horizontal:19.w),
        child:Form(key:_form,child:Column(children:[
          SizedBox(height:43.h),
          Image.asset(AppAssets.brandSymbolRaster,width:132.w,height:122.h,fit:BoxFit.contain),
          SizedBox(height:66.h),
          AppField(controller:_email,hint:'Email',icon:'assets/icons/email.svg',
            keyboardType:TextInputType.emailAddress,autofillHints:const [AutofillHints.email],
            validator:(v)=>(v??'').contains('@')?null:'Enter a valid email'),
          SizedBox(height:22.h),
          AppField(controller:_password,hint:'Password',icon:'assets/icons/lock.svg',
            obscure:_obscure,onToggleObscure:()=>setState(()=>_obscure=!_obscure),
            autofillHints:const [AutofillHints.password],
            validator:(v)=>(v??'').isEmpty?'Password is required':null),
          SizedBox(height:15.h),
          Align(alignment:Alignment.centerRight,child:SizedBox(height:24.h,
            child:InkWell(onTap:()=>Navigator.pushNamed(context,AppRouter.forgotPassword),
              child:Align(alignment:Alignment.centerRight,
                child:Text(AppStrings.text(context,'Forget Password ?'),style:TextStyle(
                  color:AppColors.accent,fontSize:13.sp)))))),
          SizedBox(height:28.h),
          BlocBuilder<AuthCubit,AuthState>(builder:(context,state)=>PrimaryButton(
            text:'Login',busy:state.status==AuthStatus.working,onPressed:_submit)),
          SizedBox(height:20.h),
          Row(mainAxisAlignment:MainAxisAlignment.center,children:[
            Text(AppStrings.text(context,"Don't Have Account ? "),style:TextStyle(fontSize:14.sp)),
            GestureDetector(onTap:()=>Navigator.pushNamed(context,AppRouter.register),
              child:Text(AppStrings.text(context,'Create One'),style:TextStyle(color:AppColors.accent,
                fontWeight:FontWeight.w700,fontSize:14.sp))),
          ]),
          SizedBox(height:30.h),
          Row(mainAxisAlignment:MainAxisAlignment.center,children:[
            Container(width:92.w,height:1,color:AppColors.accent),
            Padding(padding:EdgeInsets.symmetric(horizontal:14.w),child:
              Text(AppStrings.text(context,'OR'),style:TextStyle(color:AppColors.accent,fontSize:15.sp))),
            Container(width:92.w,height:1,color:AppColors.accent),
          ]),
          SizedBox(height:30.h),
          BlocBuilder<AuthCubit,AuthState>(builder:(context,state)=>PrimaryButton(
            text:'Login With Google',busy:state.status==AuthStatus.working,
            onPressed:()=>context.read<AuthCubit>().loginWithGoogle())),
          SizedBox(height:32.h),
          const LanguageSwitcher(),
          SizedBox(height:22.h),
        ]))),
      ),
    )));
}
