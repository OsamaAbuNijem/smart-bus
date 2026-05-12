import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/features/parent/data/datasources/parent_remote_datasource.dart';
import 'package:smart_bus/features/parent/domain/entities/absence_request_item.dart';
import 'package:smart_bus/features/parent/domain/entities/child_trip.dart';
import 'package:smart_bus/features/parent/domain/entities/live_tracking.dart';
import 'package:smart_bus/features/parent/domain/entities/parent_child.dart';
import 'package:smart_bus/features/parent/domain/entities/student_info.dart';

part 'parent_repository.g.dart';

class ParentRepository {
  ParentRepository(this._remote);
  final ParentRemoteDataSource _remote;

  Future<List<ParentChild>> getChildren(String parentId) async {
    final dto = await _remote.getParent(parentId);
    return dto.children
        .map((c) => ParentChild(
              id: c.id,
              fullName: c.fullName,
              fullNameEn: c.fullNameEn,
              grade: c.grade,
              className: c.className,
              routeName: c.routeName,
              homeArea: c.homeArea,
            ))
        .toList();
  }

  Future<LiveTracking> getLiveTracking({
    required String parentId,
    required String studentId,
  }) async {
    final dto = await _remote.getLiveTracking(
      parentId: parentId,
      studentId: studentId,
    );
    return LiveTracking(
      tripId: dto.tripId,
      tripStatus: dto.tripStatus,
      tripType: dto.tripType,
      scheduledDeparture: dto.scheduledDeparture,
      actualDeparture: dto.actualDeparture,
      actualArrival: dto.actualArrival,
      boardingTime: dto.boardingTime,
      boardingStatus: dto.boardingStatus,
      busId: dto.busId,
      busPlateNumber: dto.busPlateNumber,
      busLocation: dto.busLocation == null
          ? null
          : BusLocation(
              latitude: dto.busLocation!.latitude,
              longitude: dto.busLocation!.longitude,
              speed: dto.busLocation!.speed,
              heading: dto.busLocation!.heading,
              timestamp: dto.busLocation!.timestamp,
            ),
      driverName: dto.driverName,
      driverPhone: dto.driverPhone,
      assistantName: dto.assistantName,
      assistantPhone: dto.assistantPhone,
      studentFullName: dto.studentFullName,
      homeLatitude: dto.homeLatitude,
      homeLongitude: dto.homeLongitude,
      homeAddress: dto.homeAddress,
      schoolName: dto.schoolName,
      schoolLatitude: dto.schoolLatitude,
      schoolLongitude: dto.schoolLongitude,
    );
  }

  Future<StudentInfo> getStudent({
    required String parentId,
    required String studentId,
  }) async {
    final dto = await _remote.getStudent(
      parentId: parentId,
      studentId: studentId,
    );
    return StudentInfo(
      id: dto.id,
      fullName: dto.fullName,
      fullNameEn: dto.fullNameEn,
      nationalNumber: dto.nationalNumber,
      grade: dto.grade,
      className: dto.className,
      dateOfBirth: dto.dateOfBirth,
      schoolName: dto.schoolName,
      schoolAddress: dto.schoolAddress,
      homeAddress: dto.homeAddress,
      homeArea: dto.homeArea,
      homeStreet: dto.homeStreet,
      notes: dto.notes,
      routeName: dto.routeName,
      pickupStopName: dto.pickupStopName,
      allergies: dto.allergies,
      parent: dto.parent == null
          ? null
          : StudentContact(
              id: dto.parent!.id,
              name: dto.parent!.name,
              phoneNumber: dto.parent!.phoneNumber,
              relation: dto.parent!.relation,
              address: dto.parent!.address,
            ),
    );
  }

  Future<String> submitAbsenceRequest({
    required String studentId,
    required DateTime date,
    required String tripType,
    required String reason,
    String? driverNote,
  }) {
    return _remote.submitAbsenceRequest(
      studentId: studentId,
      date: date,
      tripType: tripType,
      reason: reason,
      driverNote: driverNote,
    );
  }

  Future<List<AbsenceRequestItem>> getAbsenceRequests(String studentId) async {
    final list = await _remote.getAbsenceRequests(studentId);
    return list.map(AbsenceRequestItem.fromJson).toList();
  }

  Future<void> cancelAbsenceRequest(String id) =>
      _remote.cancelAbsenceRequest(id);

  Future<void> updateChildProfile({
    required String parentId,
    required String studentId,
    required String fullName,
    required String grade,
    String? className,
    String? notes,
    required String parentName,
    required String parentPhone,
  }) {
    return _remote.updateChildProfile(
      parentId: parentId,
      studentId: studentId,
      fullName: fullName,
      grade: grade,
      className: className,
      notes: notes,
      parentName: parentName,
      parentPhone: parentPhone,
    );
  }

  Future<List<ChildTrip>> getChildTrips({
    required String parentId,
    required String studentId,
    int pageSize = 10,
  }) async {
    final list = await _remote.getChildTrips(
      parentId: parentId,
      studentId: studentId,
      pageSize: pageSize,
    );
    return list
        .map((dto) => ChildTrip(
              tripId: dto.tripId,
              tripType: dto.tripType,
              tripDate: dto.tripDate,
              busPlateNumber: dto.busPlateNumber,
              driverName: dto.driverName,
              assistantName: dto.assistantName,
              routeName: dto.routeName,
              pickupStopName: dto.pickupStopName,
              dropoffStopName: dto.dropoffStopName,
              scheduledDeparture: dto.scheduledDeparture,
              actualDeparture: dto.actualDeparture,
              actualArrival: dto.actualArrival,
              boardingTime: dto.boardingTime,
              dropoffTime: dto.dropoffTime,
              boardingStatus: BoardingStatusX.fromApi(dto.boardingStatus),
              tripPhase: TripPhaseX.fromApi(dto.tripStatus),
              durationMinutes: dto.durationMinutes,
              delayMinutes: dto.delayMinutes,
              resultTag: TripResultTagX.fromApi(dto.resultTag),
            ))
        .toList();
  }
}

@Riverpod(keepAlive: true)
ParentRepository parentRepository(Ref ref) =>
    ParentRepository(ref.watch(parentRemoteDataSourceProvider));
