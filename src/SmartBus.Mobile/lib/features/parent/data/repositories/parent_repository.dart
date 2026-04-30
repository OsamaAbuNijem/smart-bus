import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/features/parent/data/datasources/parent_remote_datasource.dart';
import 'package:smart_bus/features/parent/domain/entities/child_trip.dart';
import 'package:smart_bus/features/parent/domain/entities/parent_child.dart';

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
