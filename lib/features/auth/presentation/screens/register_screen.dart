import '../../../../core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/avatar_picker.dart';
import '../../../settings/presentation/widgets/language_switcher.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState()=>_RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final _form=GlobalKey<FormState>();
  final _name=TextEditingController();
  final _email=TextEditingController();
  final _password=TextEditingController();
  final _confirm=TextEditingController();
  final _phone=TextEditingController();
  int _avatar=7;
  bool _hidden=true;
  bool _navigated=false;
  @override
  void dispose(){for(final c in [_name,_email,_password,_confirm,_phone]){c.dispose();}super.dispose();}
  Future<void> _pick() async {
    final value=await showAvatarPicker(context,_avatar);
    if(value!=null && mounted)setState(()=>_avatar=value);
  }
  Future<void> _register() async {
    if(!(_form.currentState?.validate()??false))return;
    await context.read<AuthCubit>().register(_name.text.trim(),_email.text.trim(),
      _password.text,phoneNumber:_phone.text.trim(),avatarIndex:_avatar);
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
      child:Padding(padding:EdgeInsets.symmetric(horizontal:16.w),child:Form(
        key:_form,child:Column(children:[
          SizedBox(height:0.h),
          Row(children:[
            IconButton(onPressed:()=>Navigator.maybePop(context),
              icon:AppIcon('assets/icons/back.svg',size:27,color:AppColors.accent)),
            Expanded(child:Text(AppStrings.text(context,'Register'),textAlign:TextAlign.center,
              style:TextStyle(fontSize:17.sp,color:AppColors.accent))),
            SizedBox(width:42.w),
          ]),
          SizedBox(height:2.h),
          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
            AvatarCircle(index:1,size:94,onTap:_pick),
            AvatarCircle(index:_avatar,size:158,onTap:_pick),
            AvatarCircle(index:0,size:94,onTap:_pick),
          ]),
          SizedBox(height:9.h),
          Text(AppStrings.text(context,'Avatar'),style:TextStyle(fontSize:16.sp)),
          SizedBox(height:13.h),
          AppField(controller:_name,hint:'Name',icon:'assets/icons/id.svg',
            validator:(v)=>(v??'').trim().length<2?'Name is required':null),
          SizedBox(height:24.h),
          AppField(controller:_email,hint:'Email',icon:'assets/icons/email.svg',
            keyboardType:TextInputType.emailAddress,
            validator:(v)=>(v??'').contains('@')?null:'Invalid email'),
          SizedBox(height:24.h),
          AppField(controller:_password,hint:'Password',icon:'assets/icons/lock.svg',
            obscure:_hidden,onToggleObscure:()=>setState(()=>_hidden=!_hidden),
            validator:(v)=>(v??'').length>=6?null:'Use 6 or more characters'),
          SizedBox(height:24.h),
          AppField(controller:_confirm,hint:'Confirm Password',icon:'assets/icons/lock.svg',
            obscure:_hidden,onToggleObscure:()=>setState(()=>_hidden=!_hidden),
            validator:(v)=>v==_password.text?null:'Passwords do not match'),
          SizedBox(height:24.h),
          AppField(controller:_phone,hint:'Phone Number',icon:'assets/icons/phone.svg',
            keyboardType:TextInputType.phone,
            validator:(v)=>(v??'').trim().isEmpty?'Phone number is required':null),
          SizedBox(height:24.h),
          BlocBuilder<AuthCubit,AuthState>(builder:(context,state)=>PrimaryButton(
            text:'Create Account',busy:state.status==AuthStatus.working,
            onPressed:_register)),
          SizedBox(height:17.h),
          Row(mainAxisAlignment:MainAxisAlignment.center,children:[
            Text(AppStrings.text(context,'Already Have Account ? '),style:TextStyle(fontSize:14.sp)),
            GestureDetector(onTap:()=>Navigator.pop(context),child:
              Text(AppStrings.text(context,'Login'),style:TextStyle(color:AppColors.accent,
                fontWeight:FontWeight.w700,fontSize:14.sp))),
          ]),
          SizedBox(height:17.h),const LanguageSwitcher(),SizedBox(height:20.h),
        ]),
      )),
    ))));
}
