// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FoodCard {

 String get id; String get name;/// Grams of protein per serving. Clamped 1..120 by the editor.
 int get proteinGrams;/// Key into [ProteinIcons.byName] — a string, so the stored document is
/// not coupled to Flutter's icon codepoints.
 String get icon;/// Catalog ordering. Also determines the tile colour, which cycles
/// `AppColors.tilePalette` by the card's index in this ordering.
 DateTime get createdAt;
/// Create a copy of FoodCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodCardCopyWith<FoodCard> get copyWith => _$FoodCardCopyWithImpl<FoodCard>(this as FoodCard, _$identity);

  /// Serializes this FoodCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodCard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.proteinGrams, proteinGrams) || other.proteinGrams == proteinGrams)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,proteinGrams,icon,createdAt);

@override
String toString() {
  return 'FoodCard(id: $id, name: $name, proteinGrams: $proteinGrams, icon: $icon, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FoodCardCopyWith<$Res>  {
  factory $FoodCardCopyWith(FoodCard value, $Res Function(FoodCard) _then) = _$FoodCardCopyWithImpl;
@useResult
$Res call({
 String id, String name, int proteinGrams, String icon, DateTime createdAt
});




}
/// @nodoc
class _$FoodCardCopyWithImpl<$Res>
    implements $FoodCardCopyWith<$Res> {
  _$FoodCardCopyWithImpl(this._self, this._then);

  final FoodCard _self;
  final $Res Function(FoodCard) _then;

/// Create a copy of FoodCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? proteinGrams = null,Object? icon = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,proteinGrams: null == proteinGrams ? _self.proteinGrams : proteinGrams // ignore: cast_nullable_to_non_nullable
as int,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodCard].
extension FoodCardPatterns on FoodCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodCard value)  $default,){
final _that = this;
switch (_that) {
case _FoodCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodCard value)?  $default,){
final _that = this;
switch (_that) {
case _FoodCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int proteinGrams,  String icon,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodCard() when $default != null:
return $default(_that.id,_that.name,_that.proteinGrams,_that.icon,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int proteinGrams,  String icon,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FoodCard():
return $default(_that.id,_that.name,_that.proteinGrams,_that.icon,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int proteinGrams,  String icon,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FoodCard() when $default != null:
return $default(_that.id,_that.name,_that.proteinGrams,_that.icon,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodCard implements FoodCard {
  const _FoodCard({required this.id, required this.name, required this.proteinGrams, required this.icon, required this.createdAt});
  factory _FoodCard.fromJson(Map<String, dynamic> json) => _$FoodCardFromJson(json);

@override final  String id;
@override final  String name;
/// Grams of protein per serving. Clamped 1..120 by the editor.
@override final  int proteinGrams;
/// Key into [ProteinIcons.byName] — a string, so the stored document is
/// not coupled to Flutter's icon codepoints.
@override final  String icon;
/// Catalog ordering. Also determines the tile colour, which cycles
/// `AppColors.tilePalette` by the card's index in this ordering.
@override final  DateTime createdAt;

/// Create a copy of FoodCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodCardCopyWith<_FoodCard> get copyWith => __$FoodCardCopyWithImpl<_FoodCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodCard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.proteinGrams, proteinGrams) || other.proteinGrams == proteinGrams)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,proteinGrams,icon,createdAt);

@override
String toString() {
  return 'FoodCard(id: $id, name: $name, proteinGrams: $proteinGrams, icon: $icon, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FoodCardCopyWith<$Res> implements $FoodCardCopyWith<$Res> {
  factory _$FoodCardCopyWith(_FoodCard value, $Res Function(_FoodCard) _then) = __$FoodCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int proteinGrams, String icon, DateTime createdAt
});




}
/// @nodoc
class __$FoodCardCopyWithImpl<$Res>
    implements _$FoodCardCopyWith<$Res> {
  __$FoodCardCopyWithImpl(this._self, this._then);

  final _FoodCard _self;
  final $Res Function(_FoodCard) _then;

/// Create a copy of FoodCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? proteinGrams = null,Object? icon = null,Object? createdAt = null,}) {
  return _then(_FoodCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,proteinGrams: null == proteinGrams ? _self.proteinGrams : proteinGrams // ignore: cast_nullable_to_non_nullable
as int,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
