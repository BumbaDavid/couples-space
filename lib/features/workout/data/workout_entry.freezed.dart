// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutEntry {

 String get id; String get exerciseId; List<WorkoutSet> get sets; DateTime get date;// endurance fields (null for strength entries)
 int? get durationMinutes; double? get distanceKm; double? get speed; int? get resistance;
/// Create a copy of WorkoutEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutEntryCopyWith<WorkoutEntry> get copyWith => _$WorkoutEntryCopyWithImpl<WorkoutEntry>(this as WorkoutEntry, _$identity);

  /// Serializes this WorkoutEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&const DeepCollectionEquality().equals(other.sets, sets)&&(identical(other.date, date) || other.date == date)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.resistance, resistance) || other.resistance == resistance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,const DeepCollectionEquality().hash(sets),date,durationMinutes,distanceKm,speed,resistance);

@override
String toString() {
  return 'WorkoutEntry(id: $id, exerciseId: $exerciseId, sets: $sets, date: $date, durationMinutes: $durationMinutes, distanceKm: $distanceKm, speed: $speed, resistance: $resistance)';
}


}

/// @nodoc
abstract mixin class $WorkoutEntryCopyWith<$Res>  {
  factory $WorkoutEntryCopyWith(WorkoutEntry value, $Res Function(WorkoutEntry) _then) = _$WorkoutEntryCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, List<WorkoutSet> sets, DateTime date, int? durationMinutes, double? distanceKm, double? speed, int? resistance
});




}
/// @nodoc
class _$WorkoutEntryCopyWithImpl<$Res>
    implements $WorkoutEntryCopyWith<$Res> {
  _$WorkoutEntryCopyWithImpl(this._self, this._then);

  final WorkoutEntry _self;
  final $Res Function(WorkoutEntry) _then;

/// Create a copy of WorkoutEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? sets = null,Object? date = null,Object? durationMinutes = freezed,Object? distanceKm = freezed,Object? speed = freezed,Object? resistance = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<WorkoutSet>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,resistance: freezed == resistance ? _self.resistance : resistance // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutEntry].
extension WorkoutEntryPatterns on WorkoutEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutEntry value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutEntry value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  List<WorkoutSet> sets,  DateTime date,  int? durationMinutes,  double? distanceKm,  double? speed,  int? resistance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutEntry() when $default != null:
return $default(_that.id,_that.exerciseId,_that.sets,_that.date,_that.durationMinutes,_that.distanceKm,_that.speed,_that.resistance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  List<WorkoutSet> sets,  DateTime date,  int? durationMinutes,  double? distanceKm,  double? speed,  int? resistance)  $default,) {final _that = this;
switch (_that) {
case _WorkoutEntry():
return $default(_that.id,_that.exerciseId,_that.sets,_that.date,_that.durationMinutes,_that.distanceKm,_that.speed,_that.resistance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  List<WorkoutSet> sets,  DateTime date,  int? durationMinutes,  double? distanceKm,  double? speed,  int? resistance)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutEntry() when $default != null:
return $default(_that.id,_that.exerciseId,_that.sets,_that.date,_that.durationMinutes,_that.distanceKm,_that.speed,_that.resistance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutEntry implements WorkoutEntry {
  const _WorkoutEntry({required this.id, required this.exerciseId, final  List<WorkoutSet> sets = const [], required this.date, this.durationMinutes, this.distanceKm, this.speed, this.resistance}): _sets = sets;
  factory _WorkoutEntry.fromJson(Map<String, dynamic> json) => _$WorkoutEntryFromJson(json);

@override final  String id;
@override final  String exerciseId;
 final  List<WorkoutSet> _sets;
@override@JsonKey() List<WorkoutSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

@override final  DateTime date;
// endurance fields (null for strength entries)
@override final  int? durationMinutes;
@override final  double? distanceKm;
@override final  double? speed;
@override final  int? resistance;

/// Create a copy of WorkoutEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutEntryCopyWith<_WorkoutEntry> get copyWith => __$WorkoutEntryCopyWithImpl<_WorkoutEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&const DeepCollectionEquality().equals(other._sets, _sets)&&(identical(other.date, date) || other.date == date)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.resistance, resistance) || other.resistance == resistance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,const DeepCollectionEquality().hash(_sets),date,durationMinutes,distanceKm,speed,resistance);

@override
String toString() {
  return 'WorkoutEntry(id: $id, exerciseId: $exerciseId, sets: $sets, date: $date, durationMinutes: $durationMinutes, distanceKm: $distanceKm, speed: $speed, resistance: $resistance)';
}


}

/// @nodoc
abstract mixin class _$WorkoutEntryCopyWith<$Res> implements $WorkoutEntryCopyWith<$Res> {
  factory _$WorkoutEntryCopyWith(_WorkoutEntry value, $Res Function(_WorkoutEntry) _then) = __$WorkoutEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, List<WorkoutSet> sets, DateTime date, int? durationMinutes, double? distanceKm, double? speed, int? resistance
});




}
/// @nodoc
class __$WorkoutEntryCopyWithImpl<$Res>
    implements _$WorkoutEntryCopyWith<$Res> {
  __$WorkoutEntryCopyWithImpl(this._self, this._then);

  final _WorkoutEntry _self;
  final $Res Function(_WorkoutEntry) _then;

/// Create a copy of WorkoutEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? sets = null,Object? date = null,Object? durationMinutes = freezed,Object? distanceKm = freezed,Object? speed = freezed,Object? resistance = freezed,}) {
  return _then(_WorkoutEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<WorkoutSet>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,resistance: freezed == resistance ? _self.resistance : resistance // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
