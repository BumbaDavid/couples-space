// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'protein_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProteinEntry {

 String get id;/// Day bucket as `yyyy-MM-dd`. A string rather than a Timestamp so day
/// identity is exact and immune to timezone/DST drift — see
/// `docs/superpowers/specs/2026-08-08-protein-tracker-design.md`.
 String get day; String get cardId;/// Snapshotted from the card at log time. Renaming or deleting a card must
/// never rewrite history or change a past weekly average.
 String get name; String get icon;/// Grams per single serving. Clamped 1..200 by the entry editor.
 int get unit;/// How many identical servings this row represents. Repeat taps of the
/// same card in the same day+slot at the same unit increment this instead
/// of creating another row.
 int get count; ProteinSlot get slot;
/// Create a copy of ProteinEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProteinEntryCopyWith<ProteinEntry> get copyWith => _$ProteinEntryCopyWithImpl<ProteinEntry>(this as ProteinEntry, _$identity);

  /// Serializes this ProteinEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProteinEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.count, count) || other.count == count)&&(identical(other.slot, slot) || other.slot == slot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,day,cardId,name,icon,unit,count,slot);

@override
String toString() {
  return 'ProteinEntry(id: $id, day: $day, cardId: $cardId, name: $name, icon: $icon, unit: $unit, count: $count, slot: $slot)';
}


}

/// @nodoc
abstract mixin class $ProteinEntryCopyWith<$Res>  {
  factory $ProteinEntryCopyWith(ProteinEntry value, $Res Function(ProteinEntry) _then) = _$ProteinEntryCopyWithImpl;
@useResult
$Res call({
 String id, String day, String cardId, String name, String icon, int unit, int count, ProteinSlot slot
});




}
/// @nodoc
class _$ProteinEntryCopyWithImpl<$Res>
    implements $ProteinEntryCopyWith<$Res> {
  _$ProteinEntryCopyWithImpl(this._self, this._then);

  final ProteinEntry _self;
  final $Res Function(ProteinEntry) _then;

/// Create a copy of ProteinEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? day = null,Object? cardId = null,Object? name = null,Object? icon = null,Object? unit = null,Object? count = null,Object? slot = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as ProteinSlot,
  ));
}

}


/// Adds pattern-matching-related methods to [ProteinEntry].
extension ProteinEntryPatterns on ProteinEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProteinEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProteinEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProteinEntry value)  $default,){
final _that = this;
switch (_that) {
case _ProteinEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProteinEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ProteinEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String day,  String cardId,  String name,  String icon,  int unit,  int count,  ProteinSlot slot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProteinEntry() when $default != null:
return $default(_that.id,_that.day,_that.cardId,_that.name,_that.icon,_that.unit,_that.count,_that.slot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String day,  String cardId,  String name,  String icon,  int unit,  int count,  ProteinSlot slot)  $default,) {final _that = this;
switch (_that) {
case _ProteinEntry():
return $default(_that.id,_that.day,_that.cardId,_that.name,_that.icon,_that.unit,_that.count,_that.slot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String day,  String cardId,  String name,  String icon,  int unit,  int count,  ProteinSlot slot)?  $default,) {final _that = this;
switch (_that) {
case _ProteinEntry() when $default != null:
return $default(_that.id,_that.day,_that.cardId,_that.name,_that.icon,_that.unit,_that.count,_that.slot);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProteinEntry implements ProteinEntry {
  const _ProteinEntry({required this.id, required this.day, required this.cardId, required this.name, required this.icon, required this.unit, this.count = 1, required this.slot});
  factory _ProteinEntry.fromJson(Map<String, dynamic> json) => _$ProteinEntryFromJson(json);

@override final  String id;
/// Day bucket as `yyyy-MM-dd`. A string rather than a Timestamp so day
/// identity is exact and immune to timezone/DST drift — see
/// `docs/superpowers/specs/2026-08-08-protein-tracker-design.md`.
@override final  String day;
@override final  String cardId;
/// Snapshotted from the card at log time. Renaming or deleting a card must
/// never rewrite history or change a past weekly average.
@override final  String name;
@override final  String icon;
/// Grams per single serving. Clamped 1..200 by the entry editor.
@override final  int unit;
/// How many identical servings this row represents. Repeat taps of the
/// same card in the same day+slot at the same unit increment this instead
/// of creating another row.
@override@JsonKey() final  int count;
@override final  ProteinSlot slot;

/// Create a copy of ProteinEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProteinEntryCopyWith<_ProteinEntry> get copyWith => __$ProteinEntryCopyWithImpl<_ProteinEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProteinEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProteinEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.count, count) || other.count == count)&&(identical(other.slot, slot) || other.slot == slot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,day,cardId,name,icon,unit,count,slot);

@override
String toString() {
  return 'ProteinEntry(id: $id, day: $day, cardId: $cardId, name: $name, icon: $icon, unit: $unit, count: $count, slot: $slot)';
}


}

/// @nodoc
abstract mixin class _$ProteinEntryCopyWith<$Res> implements $ProteinEntryCopyWith<$Res> {
  factory _$ProteinEntryCopyWith(_ProteinEntry value, $Res Function(_ProteinEntry) _then) = __$ProteinEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String day, String cardId, String name, String icon, int unit, int count, ProteinSlot slot
});




}
/// @nodoc
class __$ProteinEntryCopyWithImpl<$Res>
    implements _$ProteinEntryCopyWith<$Res> {
  __$ProteinEntryCopyWithImpl(this._self, this._then);

  final _ProteinEntry _self;
  final $Res Function(_ProteinEntry) _then;

/// Create a copy of ProteinEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? day = null,Object? cardId = null,Object? name = null,Object? icon = null,Object? unit = null,Object? count = null,Object? slot = null,}) {
  return _then(_ProteinEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as ProteinSlot,
  ));
}


}

// dart format on
