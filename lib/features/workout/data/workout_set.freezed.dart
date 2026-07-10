// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutSet {

 int get reps; double? get weight; bool get failure;
/// Create a copy of WorkoutSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSetCopyWith<WorkoutSet> get copyWith => _$WorkoutSetCopyWithImpl<WorkoutSet>(this as WorkoutSet, _$identity);

  /// Serializes this WorkoutSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSet&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.failure, failure) || other.failure == failure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reps,weight,failure);

@override
String toString() {
  return 'WorkoutSet(reps: $reps, weight: $weight, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $WorkoutSetCopyWith<$Res>  {
  factory $WorkoutSetCopyWith(WorkoutSet value, $Res Function(WorkoutSet) _then) = _$WorkoutSetCopyWithImpl;
@useResult
$Res call({
 int reps, double? weight, bool failure
});




}
/// @nodoc
class _$WorkoutSetCopyWithImpl<$Res>
    implements $WorkoutSetCopyWith<$Res> {
  _$WorkoutSetCopyWithImpl(this._self, this._then);

  final WorkoutSet _self;
  final $Res Function(WorkoutSet) _then;

/// Create a copy of WorkoutSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reps = null,Object? weight = freezed,Object? failure = null,}) {
  return _then(_self.copyWith(
reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSet].
extension WorkoutSetPatterns on WorkoutSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSet() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSet value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSet():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSet value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSet() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int reps,  double? weight,  bool failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSet() when $default != null:
return $default(_that.reps,_that.weight,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int reps,  double? weight,  bool failure)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSet():
return $default(_that.reps,_that.weight,_that.failure);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int reps,  double? weight,  bool failure)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSet() when $default != null:
return $default(_that.reps,_that.weight,_that.failure);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutSet implements WorkoutSet {
  const _WorkoutSet({required this.reps, this.weight, this.failure = false});
  factory _WorkoutSet.fromJson(Map<String, dynamic> json) => _$WorkoutSetFromJson(json);

@override final  int reps;
@override final  double? weight;
@override@JsonKey() final  bool failure;

/// Create a copy of WorkoutSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSetCopyWith<_WorkoutSet> get copyWith => __$WorkoutSetCopyWithImpl<_WorkoutSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSet&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.failure, failure) || other.failure == failure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reps,weight,failure);

@override
String toString() {
  return 'WorkoutSet(reps: $reps, weight: $weight, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSetCopyWith<$Res> implements $WorkoutSetCopyWith<$Res> {
  factory _$WorkoutSetCopyWith(_WorkoutSet value, $Res Function(_WorkoutSet) _then) = __$WorkoutSetCopyWithImpl;
@override @useResult
$Res call({
 int reps, double? weight, bool failure
});




}
/// @nodoc
class __$WorkoutSetCopyWithImpl<$Res>
    implements _$WorkoutSetCopyWith<$Res> {
  __$WorkoutSetCopyWithImpl(this._self, this._then);

  final _WorkoutSet _self;
  final $Res Function(_WorkoutSet) _then;

/// Create a copy of WorkoutSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reps = null,Object? weight = freezed,Object? failure = null,}) {
  return _then(_WorkoutSet(
reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
