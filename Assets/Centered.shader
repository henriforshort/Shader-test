Shader "Unlit/Centered"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define TAU 6.28

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float GetWave(float2 uv)
            {
                float radialDistance = saturate(length(uv*2-1));
                float hypno = cos((radialDistance - _Time.y * .1) * TAU * 10);
                return hypno * (1 - radialDistance);
            }

            v2f vert (appdata v)
            {
                v2f o;
                //v.vertex.y = GetWave(v.uv) * .2;
                v.vertex.y = cos((v.uv.x + _Time.y * .2) * TAU * 2) * .2;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return GetWave(i.uv);
            }
            ENDCG
        }
    }
}
