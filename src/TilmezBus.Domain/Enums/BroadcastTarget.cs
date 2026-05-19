namespace TilmezBus.Domain.Enums;

/// <summary>
/// Audience for a SuperAdmin push broadcast.
///   * AllUsers     — everyone with a Parent / Driver / Assistant / Admin role.
///   * SchoolUsers  — parents of children at the selected schools + each
///                    selected school's Admin user (the AdminEmail account).
///   * SchoolAdmins — every Admin-role user (filtered to the selected
///                    schools when SchoolIds is non-empty).
/// </summary>
public enum BroadcastTarget
{
    AllUsers     = 0,
    SchoolUsers  = 1,
    SchoolAdmins = 2
}
