// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OnboardingState()';
}


}

/// @nodoc
class $OnboardingStateCopyWith<$Res>  {
$OnboardingStateCopyWith(OnboardingState _, $Res Function(OnboardingState) __);
}


/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OnboardingActive value)?  active,TResult Function( OnboardingCompleted value)?  completed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OnboardingActive() when active != null:
return active(_that);case OnboardingCompleted() when completed != null:
return completed(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OnboardingActive value)  active,required TResult Function( OnboardingCompleted value)  completed,}){
final _that = this;
switch (_that) {
case OnboardingActive():
return active(_that);case OnboardingCompleted():
return completed(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OnboardingActive value)?  active,TResult? Function( OnboardingCompleted value)?  completed,}){
final _that = this;
switch (_that) {
case OnboardingActive() when active != null:
return active(_that);case OnboardingCompleted() when completed != null:
return completed(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int currentPage,  int totalPages)?  active,TResult Function()?  completed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OnboardingActive() when active != null:
return active(_that.currentPage,_that.totalPages);case OnboardingCompleted() when completed != null:
return completed();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int currentPage,  int totalPages)  active,required TResult Function()  completed,}) {final _that = this;
switch (_that) {
case OnboardingActive():
return active(_that.currentPage,_that.totalPages);case OnboardingCompleted():
return completed();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int currentPage,  int totalPages)?  active,TResult? Function()?  completed,}) {final _that = this;
switch (_that) {
case OnboardingActive() when active != null:
return active(_that.currentPage,_that.totalPages);case OnboardingCompleted() when completed != null:
return completed();case _:
  return null;

}
}

}

/// @nodoc


class OnboardingActive implements OnboardingState {
  const OnboardingActive({required this.currentPage, required this.totalPages});
  

/// Index of the currently visible page
 final  int currentPage;
/// Total number of onboarding pages
 final  int totalPages;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingActiveCopyWith<OnboardingActive> get copyWith => _$OnboardingActiveCopyWithImpl<OnboardingActive>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingActive&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}


@override
int get hashCode => Object.hash(runtimeType,currentPage,totalPages);

@override
String toString() {
  return 'OnboardingState.active(currentPage: $currentPage, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class $OnboardingActiveCopyWith<$Res> implements $OnboardingStateCopyWith<$Res> {
  factory $OnboardingActiveCopyWith(OnboardingActive value, $Res Function(OnboardingActive) _then) = _$OnboardingActiveCopyWithImpl;
@useResult
$Res call({
 int currentPage, int totalPages
});




}
/// @nodoc
class _$OnboardingActiveCopyWithImpl<$Res>
    implements $OnboardingActiveCopyWith<$Res> {
  _$OnboardingActiveCopyWithImpl(this._self, this._then);

  final OnboardingActive _self;
  final $Res Function(OnboardingActive) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentPage = null,Object? totalPages = null,}) {
  return _then(OnboardingActive(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class OnboardingCompleted implements OnboardingState {
  const OnboardingCompleted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingCompleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OnboardingState.completed()';
}


}




// dart format on
