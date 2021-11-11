Shader "Custom/Metaball"
{
    Properties
    {
        _Radius("Radius", Range(0.0,1.0)) = 0.3
    }
    SubShader
    {
        //衝突しないピクセルは透明
        Tags
        {
            "Queue" = "Transparent"
            "LightMode" = "ForwardBase"
        }
        LOD 100

        Pass
        {
            ZWrite On
            //アルファ値が機能するために必要
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : POSITION1;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //ローカル→ワールド座標に変換
                o.pos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 _MetaballTransforms[256];

            //球の距離関数
            float sphere(float4 t, float3 pos)
            {
                return length(t.xyz - pos) - t.w;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // レイの初期位置(ピクセルのワールド座標)
                float3 pos = i.pos.xyz;
                // レイの進行方向
                float3 rayDir = normalize(pos.xyz - _WorldSpaceCameraPos);

                int StepNum = 30;

                for (int i = 0; i < StepNum; i++)
                {
                    //行進する距離(球との最短距離分)
                    float marchingDist = sphere(_MetaballTransforms[0], pos);

                    //0.001以下になったら、ピクセルを白で塗って処理終了
                    if (marchingDist < 0.001)
                    {
                        return 1.0;
                    }
                    //レイの方向に行進する
                    pos.xyz += marchingDist * rayDir.xyz;
                }

                //StepNum回行進しても衝突判定がなかったら、ピクセルを透明にして処理終了
                return 0;
            }
            ENDCG
        }
    }
}