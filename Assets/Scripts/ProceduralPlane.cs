using Random = UnityEngine.Random;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class ProceduralPlane : MonoBehaviour
{
    public enum WaterType
    {
        Wire,
        Normal
    }

    public WaterType waterType =
        WaterType.Normal;

    [Range(2, 200)]
    public int size;

    public int Size
    {
        get
        {
            if (waterType == WaterType.Wire)
                return size / 2;
            else
                return size;
        }
    }

    [Range(0, 1)]
    public float noise;

    private Mesh mesh;

    private float
        sin60 = Mathf.Sin(60 * Mathf.Deg2Rad);

    private float
        cos60 = Mathf.Cos(60 * Mathf.Deg2Rad);

    private void Start() { }

    public void Generate()
    {
        GetComponent<MeshFilter>().mesh =
            mesh = new Mesh();

        List<Vector3> vertices = new List<Vector3>();
        List<Vector2> uvs = new List<Vector2>();
        List<int> triangles = new List<int>();

        GenerateVertices(uvs, vertices);
        AddTriangles(triangles);
        CreateMesh(uvs, vertices, triangles);
    }

    private void GenerateVertices(List<Vector2> uvs,
        List<Vector3> vertices)
    {
        for (int z = 0; z <= Size; z++)
        {
            bool isPair = z % 2 == 0;
            int xSize = isPair ? Size : Size + 1;

            for (int x = 0; x <= xSize; x++)
            {
                if (isPair)
                {
                    AddVertex(vertices, new Vector3(
                        x - Size / 2f, 0, z * sin60 - Size / 2f));
                    uvs.Add(new Vector2((float)x / xSize, (float)z / Size));
                }
                else
                {
                    AddVertex(vertices, new Vector3(
                        x - 0.5f - Size / 2f, 0, z * sin60 - Size / 2f));
                    uvs.Add(new Vector2((float)x / xSize, (float)z / Size));
                }
            }
        }
    }

    private void AddVertex(List<Vector3> vertices, Vector3 pos)
    {
        if (noise > 0f)
        {
            Vector2 offset = Random.insideUnitCircle * noise * 0.5f;
            pos = new Vector3(pos.x + offset.x, 0, pos.z + offset.y);
        }

        vertices.Add(pos);
    }

    private void AddTriangles(List<int> triangles)
    {
        for (int z = 0, i = 0; z < Size; z++, i++)
        {
            bool isPair = z % 2 == 0;
            int xSize = isPair ? Size : Size + 1;

            for (int x = 0; x < xSize; x++, i++)
            {
                if (isPair)
                {
                    triangles.Add(i);
                    triangles.Add(i + Size + 1);
                    triangles.Add(i + Size + 2);
                    triangles.Add(i);
                    triangles.Add(i + Size + 2);
                    triangles.Add(i + 1);

                    if (x == xSize - 1)
                    {
                        triangles.Add(i + 1);
                        triangles.Add(i + Size + 2);
                        triangles.Add(i + Size + 3);
                    }
                }
                else
                {
                    if (x != 0)
                    {
                        triangles.Add(i);
                        triangles.Add(i - 1);
                        triangles.Add(i + Size + 1);
                        triangles.Add(i);
                        triangles.Add(i + Size + 1);
                        triangles.Add(i + Size + 2);

                        if (x == xSize - 1)
                        {
                            triangles.Add(i);
                            triangles.Add(i + Size + 2);
                            triangles.Add(i + 1);
                        }
                    }
                }
            }
        }
    }

    private void CreateMesh(List<Vector2> uvs, List<Vector3> vertices,
        List<int> triangles)
    {
        if (waterType == WaterType.Wire)
        {
            Vector2[] newUvs = new Vector2[triangles.Count];
            Vector3[] newVertices = new Vector3[triangles.Count];
            for (int i = 0; i < triangles.Count; i++)
            {
                newVertices[i] = vertices[triangles[i]];
                newUvs[i] = uvs[triangles[i]];
                triangles[i] = i;
            }

            Color[] barCoords = new Color[triangles.Count];
            for (int i = 0; i < triangles.Count; i += 3)
            {
                barCoords[i] = new Color(1, 0, 0);
                barCoords[i + 1] = new Color(0, 1, 0);
                barCoords[i + 2] = new Color(0, 0, 1);
            }

            mesh.vertices = newVertices;
            mesh.triangles = triangles.ToArray();
            mesh.uv = newUvs;
            mesh.colors = barCoords;

            mesh.RecalculateNormals();
        }
        else
        {
            mesh.vertices = vertices.ToArray();
            mesh.triangles = triangles.ToArray();
            mesh.uv = uvs.ToArray();

            mesh.RecalculateNormals();
        }
    }

}
