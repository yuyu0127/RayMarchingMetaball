using System.Linq;
using UnityEngine;

[ExecuteAlways]
public class MetaballRenderer : MonoBehaviour
{
    [SerializeField] private Material metaballMaterial;
    [SerializeField] private Transform colliderParent;
    private SphereCollider[] _sphereColliders;
    private static readonly int MetaballTransforms = Shader.PropertyToID("_MetaballTransforms");


    private void Start()
    {
        _sphereColliders = colliderParent.GetComponentsInChildren<SphereCollider>();
    }

    private void Update()
    {
        var metaballTransforms = _sphereColliders.Select(col =>
        {
            var t = col.transform;
            var center = t.TransformPoint(col.center);
            return new Vector4(center.x, center.y, center.z, t.lossyScale.x * col.radius);
        }).ToArray();
        metaballMaterial.SetVectorArray(MetaballTransforms, metaballTransforms);
    }
}