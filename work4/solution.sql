-- Задача 1

WITH RECURSIVE EmployeeHierarchy AS (
    SELECT 
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM Employees
    WHERE EmployeeID = 1
    
    UNION ALL
    
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT 
    eh.EmployeeID,
    eh.Name AS EmployeeName,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS ProjectNames,
    GROUP_CONCAT(DISTINCT 
        CONCAT(t.TaskName, '') 
        ORDER BY t.TaskName SEPARATOR ', '
    ) AS TaskNames
FROM EmployeeHierarchy eh
LEFT JOIN Departments d ON eh.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON eh.RoleID = r.RoleID
LEFT JOIN Tasks t ON eh.EmployeeID = t.AssignedTo
LEFT JOIN Projects p ON t.ProjectID = p.ProjectID
GROUP BY eh.EmployeeID, eh.Name, eh.ManagerID, d.DepartmentName, r.RoleName
ORDER BY eh.Name;

-- Задача 2

WITH RECURSIVE EmployeeHierarchy AS (
    SELECT 
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM Employees
    WHERE EmployeeID = 1
    
    UNION ALL
    
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT 
    eh.EmployeeID,
    eh.Name AS EmployeeName,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS ProjectNames,
    GROUP_CONCAT(DISTINCT 
        CONCAT(t.TaskName, '')
        ORDER BY t.TaskName SEPARATOR ', '
    ) AS TaskNames,
    COUNT(DISTINCT t.TaskID) AS TotalTasks,
    (
        SELECT COUNT(*)
        FROM Employees e2
        WHERE e2.ManagerID = eh.EmployeeID
    ) AS TotalSubordinates
FROM EmployeeHierarchy eh
LEFT JOIN Departments d ON eh.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON eh.RoleID = r.RoleID
LEFT JOIN Tasks t ON eh.EmployeeID = t.AssignedTo
LEFT JOIN Projects p ON t.ProjectID = p.ProjectID
GROUP BY eh.EmployeeID, eh.Name, eh.ManagerID, d.DepartmentName, r.RoleName
ORDER BY eh.Name;

-- Задача 3

WITH RECURSIVE EmployeeHierarchy AS (
    SELECT 
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM Employees
    
    UNION ALL
    
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
),
SubordinateCount AS (
    SELECT 
        ManagerID,
        COUNT(*) AS total_subordinates
    FROM EmployeeHierarchy
    WHERE ManagerID IS NOT NULL
    GROUP BY ManagerID
)
SELECT 
    e.EmployeeID,
    e.Name AS EmployeeName,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS ProjectNames,
    GROUP_CONCAT(DISTINCT 
        CONCAT(t.TaskName, '')
        ORDER BY t.TaskName SEPARATOR ', '
    ) AS TaskNames,
    COALESCE(sc.total_subordinates, 0) AS TotalSubordinates
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
INNER JOIN Roles r ON e.RoleID = r.RoleID
LEFT JOIN Tasks t ON e.EmployeeID = t.AssignedTo
LEFT JOIN Projects p ON t.ProjectID = p.ProjectID
LEFT JOIN SubordinateCount sc ON e.EmployeeID = sc.ManagerID
WHERE r.RoleName = 'Менеджер'
  AND COALESCE(sc.total_subordinates, 0) > 0
GROUP BY e.EmployeeID, e.Name, e.ManagerID, d.DepartmentName, r.RoleName, sc.total_subordinates
ORDER BY e.EmployeeID;
