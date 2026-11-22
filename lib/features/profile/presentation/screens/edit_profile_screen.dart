import '../../../../core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/avatar_picker.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../user_data/presentation/cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState()=>_EditProfileScreenState();
}
class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name=TextEditingController();
  final _phone=TextEditingController();
  final _form=GlobalKey<FormState>();
  int avatar=7;
  bool dirty=false;
  @override
  void initState(){super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(!mounted)return;
      final doc=context.read<ProfileCubit>().state;
      final user=context.read<AuthCubit>().state.user;
      _name.text=doc.document?['displayName'] is String
          ?doc.document!['displayName'] as String :user?.displayName??'';
      _phone.text=doc.phone;
      setState(()=>avatar=doc.avatar);
    });
  }
  @override
  void dispose(){_name.dispose();_phone.dispose();super.dispose();}
  Future<void> _save() async {
    if(!(_form.currentState?.validate()??false))return;
    final saved=await context.read<ProfileCubit>().update(
      name:_name.text,phone:_phone.text,avatar:avatar);
    if(!mounted)return;
    if(saved){Navigator.pop(context);}else{
      showAppError(context,context.read<ProfileCubit>().state.failure?.message??'Update failed');
    }
  }
  Future<void> _reset() async {
    final email=context.read<AuthCubit>().state.user?.email;
    if(email==null || email.isEmpty){showAppError(context,'No email address is linked to this account.');return;}
    await context.read<AuthCubit>().resetPassword(email);
    if(!mounted)return;
    final state=context.read<AuthCubit>().state;
    showAppError(context,state.status==AuthStatus.passwordResetSent
      ?'Password reset email sent.':state.failure?.message??'Unable to send reset email.');
  }
  Future<void> _delete() async {
    final user=context.read<AuthCubit>().state.user;
    final isPassword=user?.providerIds.contains('password')??false;
    final passwordController=TextEditingController();
    final confirmation=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      backgroundColor:AppColors.surface,title:const Text('Delete Account'),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        const Text('Permanently delete your account and saved movies? This cannot be undone.'),
        if(isPassword)...[
          SizedBox(height:12.h),
          TextField(controller:passwordController,obscureText:true,
            decoration:const InputDecoration(labelText:'Current password')),
        ],
      ]),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),
        TextButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Delete',
          style:TextStyle(color:AppColors.destructive)))],
    ));
    final password=passwordController.text;
    passwordController.dispose();
    if(confirmation!=true || !mounted)return;
    await context.read<AuthCubit>().deleteAccount(
      currentPassword:isPassword?password:null);
    if(!mounted)return;
    final state=context.read<AuthCubit>().state;
    if(state.status==AuthStatus.signedOut){
      Navigator.pushNamedAndRemoveUntil(context,AppRouter.login,(_)=>false);
    } else {
      showAppError(context,state.failure?.message??'Account deletion failed.');
    }
  }
  Future<void> _pick() async {
    final selected=await showAvatarPicker(context,avatar);
    if(selected!=null && mounted)setState(()=>avatar=selected);
  }
  @override
  Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Padding(
    padding:EdgeInsets.fromLTRB(16.w,7.h,16.w,16.h),child:Column(children:[
      Row(children:[
        IconButton(onPressed:()=>Navigator.pop(context),
          icon:const AppIcon('assets/icons/back.svg',size:26,color:AppColors.accent)),
        Expanded(child:Text(AppStrings.text(context,'Pick Avatar'),textAlign:TextAlign.center,
          style:TextStyle(color:AppColors.accent,fontSize:16.sp))),
        SizedBox(width:45.w),
      ]),
      SizedBox(height:8.h),
      AvatarCircle(index:avatar,size:162,onTap:_pick),
      SizedBox(height:40.h),
      Form(key:_form,child:Column(children:[
        AppField(controller:_name,hint:'Name',icon:'assets/icons/user.svg',
          validator:(v)=>(v??'').trim().isNotEmpty?null:'Enter your name'),
        SizedBox(height:20.h),
        AppField(controller:_phone,hint:'Phone Number',icon:'assets/icons/phone.svg',
          keyboardType:TextInputType.phone,
          validator:(v)=>(v??'').trim().isNotEmpty?null:'Enter phone number'),
      ])),
      Align(alignment:Alignment.centerLeft,child:TextButton(onPressed:_reset,
        style:TextButton.styleFrom(padding:EdgeInsets.symmetric(vertical:22.h,horizontal:5.w)),
        child:Text(AppStrings.text(context,'Reset Password'),style:TextStyle(color:Colors.white,fontSize:15.sp)))),
      const Spacer(),
      PrimaryButton(text:'Delete Account',color:AppColors.destructive,
        foreground:Colors.white,height:54,onPressed:_delete),
      SizedBox(height:10.h),
      BlocBuilder<ProfileCubit,ProfileState>(builder:(context,state)=>PrimaryButton(
        text:'Update Data',height:54,busy:state.status==ProfileStatus.saving,
        onPressed:_save)),
    ]),
  )));
}
