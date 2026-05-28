// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'couple.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Couple {

 String get id; List<String> get memberIds; DateTime get createdAt;
/// Create a copy of Couple
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoupleCopyWith<Couple> get copyWith => _$CoupleCopyWithImpl<Couple>(this as Couple, _$identity);

  /// Serializes this Couple to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Couple&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.memberIds, memberIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(memberIds),createdAt);

@override
String toString() {
  return 'Couple(id: $id, memberIds: $memberIds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CoupleCopyWith<$Res>  {
  factory $CoupleCopyWith(Couple value, $Res Function(Couple) _then) = _$CoupleCopyWithImpl;
@useResult
$Res call({
 String id, List<String> memberIds, DateTime createdAt
});




}
/// @nodoc
class _$CoupleCopyWithImpl<$Res>
    implements $CoupleCopyWith<$Res> {
  _$CoupleCopyWithImpl(this._self, this._then);

  final Couple _self;
  final $Res Function(Couple) _then;

/// Create a copy of Couple
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberIds = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Couple].
extension CouplePatterns on Couple {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Couple value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Couple() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Couple value)  $default,){
final _that = this;
switch (_that) {
case _Couple():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Couple value)?  $default,){
final _that = this;
switch (_that) {
case _Couple() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<String> memberIds,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Couple() when $default != null:
return $default(_that.id,_that.memberIds,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<String> memberIds,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Couple():
return $default(_that.id,_that.memberIds,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<String> memberIds,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Couple() when $default != null:
return $default(_that.id,_that.memberIds,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Couple implements Couple {
  const _Couple({required this.id, required final  List<String> memberIds, required this.createdAt}): _memberIds = memberIds;
  factory _Couple.fromJson(Map<String, dynamic> json) => _$CoupleFromJson(json);

@override final  String id;
 final  List<String> _memberIds;
@override List<String> get memberIds {
  if (_memberIds is EqualUnmodifiableListView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberIds);
}

@override final  DateTime createdAt;

/// Create a copy of Couple
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoupleCopyWith<_Couple> get copyWith => __$CoupleCopyWithImpl<_Couple>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoupleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Couple&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._memberIds, _memberIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_memberIds),createdAt);

@override
String toString() {
  return 'Couple(id: $id, memberIds: $memberIds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CoupleCopyWith<$Res> implements $CoupleCopyWith<$Res> {
  factory _$CoupleCopyWith(_Couple value, $Res Function(_Couple) _then) = __$CoupleCopyWithImpl;
@override @useResult
$Res call({
 String id, List<String> memberIds, DateTime createdAt
});




}
/// @nodoc
class __$CoupleCopyWithImpl<$Res>
    implements _$CoupleCopyWith<$Res> {
  __$CoupleCopyWithImpl(this._self, this._then);

  final _Couple _self;
  final $Res Function(_Couple) _then;

/// Create a copy of Couple
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberIds = null,Object? createdAt = null,}) {
  return _then(_Couple(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
