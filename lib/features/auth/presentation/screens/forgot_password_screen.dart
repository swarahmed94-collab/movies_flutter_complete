import '../../../../core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState()=>_ForgotPasswordScreenState();
}
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email=TextEditingController();
  final _form=GlobalKey<FormState>();
  @override
  void dispose(){_email.dispose();super.dispose();}
  @override
  Widget build(BuildContext context)=>BlocListener<AuthCubit,AuthState>(
    listener:(context,state){
      if(state.status==AuthStatus.passwordResetSent){
        showAppError(context,'Password reset link sent. Check your email.');
      }else if(state.status==AuthStatus.failed && state.failure!=null){
        showAppError(context,state.failure!.message);
      }
    },child:Scaffold(body:SafeArea(child:SingleChildScrollView(
      child:Padding(padding:EdgeInsets.symmetric(horizontal:16.w),child:Column(children:[
        SizedBox(height:8.h),Row(children:[
          IconButton(onPressed:()=>Navigator.pop(context),icon:
            const AppIcon('assets/icons/back.svg',color:AppColors.accent)),
          Expanded(child:Text(AppStrings.text(context,'Forget Password'),textAlign:TextAlign.center,
            style:TextStyle(fontSize:16.sp,color:AppColors.accent))),
          SizedBox(width:45.w),
        ]),
        SizedBox(height:35.h),
        // Illustration is a pixel crop from the supplied Forgot Password export.
        Image.asset('assets/images/forgot_illustration.png',width:360.w,height:290.h,fit:BoxFit.contain),
        SizedBox(height:120.h),Form(key:_form,child:AppField(controller:_email,
          hint:'Email',icon:'assets/icons/email.svg',keyboardType:TextInputType.emailAddress,
          validator:(v)=>(v??'').contains('@')?null:'Enter a valid email')),
        SizedBox(height:24.h),
        BlocBuilder<AuthCubit,AuthState>(builder:(context,state)=>PrimaryButton(
          text:'Verify Email',busy:state.status==AuthStatus.working,onPressed:(){
            if(_form.currentState?.validate()??false){
              context.read<AuthCubit>().resetPassword(_email.text);
            }
          })),
      ])),
    ))));
}
