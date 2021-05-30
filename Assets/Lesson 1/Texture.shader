Shader "Unlit/Texture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Pattern ("Pattern", 2D) = "white" {}
        _Carrot ("Carrot", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            #define TAU 6.28

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _Pattern;
            sampler2D _Carrot;

            float GetWave(float coord)
            {
                float hypno = cos((coord - _Time.y * .1) * TAU * 10);
                return hypno * (1 - coord);
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.worldPosition = mul(UNITY_MATRIX_M, float4(v.vertex.xyz, 1));
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 topDownProjection = i.worldPosition.xz;
                float4 jester = tex2D(_MainTex, topDownProjection);
                float4 carrot = tex2D(_Carrot, topDownProjection);
                float pattern = tex2D(_Pattern, i.uv).x;
                float4 finalColor = lerp(carrot, jester, pattern);

                return finalColor;
            }
            ENDCG
        }
    }
}
