Shader "Unlit/Vertex Offset" {
    Properties {
        _ColorA("Color A", Color) = (1, 1, 1, 1)
        _ColorB("Color B", Color) = (1, 1, 1, 1)
        _ColorStart ("Color Start", Range(0,1)) = 0
        _ColorEnd ("Color End", Range(0,1)) = 1
    }
    SubShader {
        Tags { 
            "RenderType"="Opaque"   
        }

        Pass {            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.283185

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct MeshData { //Input data for the whole shader. All are loval space
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0; //TextCoords are uv coordinate only here
                //float2 uv2 : TEXCOORD1;
                float3 normals : NORMAL;
                //float4 tangent : TANGENT;
                //float4 color : COLOR;
                
            };

            struct Interpolators { //Output data from the vertex shader, Input data for the fragment shader
                //float2 uv : TEXCOORD0; //TextCoords can be any data channels here
                float2 uv : TEXCOORD1;
                //float4 uv3 : TEXCOORD2;
                float3 normal : TEXCOORD0;
                float4 vertex : SV_POSITION; //clip space position
            };

            float InverseLerp(float a, float b, float v) {
                return (v-a)/(b-a);
            }

            Interpolators vert (MeshData v) { //usually less vertices than pixels so calculations are better here
                float wave =  cos((v.uv.y - _Time.y * .1)*TAU*5);
                v.vertex.y += wave * .1;
                
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); //local space to clip space
                o.normal = v.normals;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target {
                return cos((i.uv.y - _Time.y * .1)*TAU*5) * .5 + .5;
            }
            ENDCG
        }
    }
}