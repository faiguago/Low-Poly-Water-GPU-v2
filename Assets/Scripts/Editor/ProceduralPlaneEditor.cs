using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ProceduralPlane))]
public class ProceduralPlaneEditor : Editor
{

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        ProceduralPlane plane = target as ProceduralPlane;

        if (GUILayout.Button("Generate"))
        {
            plane.Generate();
        }
    }

}
