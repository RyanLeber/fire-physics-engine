
#include "raylib.h"

// void DrawPixel(int posX, int posY, Color color);                                                   // Draw a pixel
// void DrawPixelV(Vector2 position, Color color);                                                    // Draw a pixel (Vector version)
// void DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color);                // Draw a line
// void DrawLineV(Vector2 startPos, Vector2 endPos, Color color);                                     // Draw a line (using gl lines)
// void DrawLineEx(Vector2 startPos, Vector2 endPos, float thick, Color color);                       // Draw a line (using triangles/quads)
// void DrawLineStrip(Vector2 *points, int pointCount, Color color);                                  // Draw lines sequence (using gl lines)
// void DrawLineBezier(Vector2 startPos, Vector2 endPos, float thick, Color color);                   // Draw line segment cubic-bezier in-out interpolation
// void DrawCircle(int centerX, int centerY, float radius, Color color);                              // Draw a color-filled circle
// void DrawCircleSector(Vector2 center, float radius, float startAngle, float endAngle, int segments, Color color);      // Draw a piece of a circle
// void DrawCircleSectorLines(Vector2 center, float radius, float startAngle, float endAngle, int segments, Color color); // Draw circle sector outline
// void DrawCircleGradient(int centerX, int centerY, float radius, Color color1, Color color2);       // Draw a gradient-filled circle
// void DrawCircleV(Vector2 center, float radius, Color color);                                       // Draw a color-filled circle (Vector version)
// void DrawCircleLines(int centerX, int centerY, float radius, Color color);                         // Draw circle outline
// void DrawCircleLinesV(Vector2 center, float radius, Color color);                                  // Draw circle outline (Vector version)


// Core
void _ClearBackground(Color *color);                         // Set background color (framebuffer clear color)
void _BeginMode3D(Camera3D *camera);                        // Begin 3D mode with custom camera (3D)
void _BeginMode2D(Camera2D *camera);                        // Begin 2D mode with custom camera (2D)

// 2D
void _DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color *color);                // Draw a line
void _DrawLineV(Vector2 *startPos, Vector2 *endPos, Color *color);                                   // Draw a line (using gl lines)

void _DrawCircle(int centerX, int centerY, float radius, Color *color);
void _DrawCircleV(Vector2 *center, float radius, Color *color);
void _DrawCircleLines(int centerX, int centerY, float radius, Color *color);                         // Draw circle outline

void _DrawRectangleV(Vector2 *position, Vector2 *size, Color *color);
void _DrawRectanglePro(Rectangle *rec, Vector2 *origin, float rotation, Color *color);
void _DrawPoly(Vector2 *center, int sides, float radius, float rotation, Color *color);
void _DrawPolyLines(Vector2 *center, int sides, float radius, float rotation, Color *color);
void _DrawPolyLinesEx(Vector2 *center, int sides, float radius, float rotation, float lineThick, Color *color);

// 3D

void _DrawCube(Vector3 *position, float width, float height, float length, Color *color);       // Draw cube MARK: DrawCube
void _DrawCubeV(Vector3 *position, Vector3 size, Color *color);                                 // Draw cube (Vector version)
void _DrawCubeWires(Vector3 *position, float width, float height, float length, Color *color);  // Draw cube wires MARK: DrawCubeWires
void _DrawCubeWiresV(Vector3 *position, Vector3 *size, Color *color);                           // Draw cube wires (Vector version)

// Text

void _DrawText(const char *text, int posX, int posY, int fontSize, Color *color);