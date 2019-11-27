import { useReducer } from "react";

const MIN_ZOOM = 1;
const MAX_ZOOM = 12;

export const initialState = {
  zoom: 1,
  activeLayerId: 1
};

export default function worldMapReducer(state, action) {
  switch (action.type) {
    case "zoomIn": {
      return { ...state, zoom: Math.min(state.zoom + 1, MAX_ZOOM) };
    }
    case "zoomOut": {
      return { ...state, zoom: Math.max(state.zoom - 1, MIN_ZOOM) };
    }
    case "zoomEnd": {
      const { zoom } = action.payload;
      return {
        ...state,
        zoom: Math.min(zoom, MAX_ZOOM)
      };
    }
    case "setActiveLayerId": {
      return { ...state, activeLayerId: Number(action.payload) };
    }
    default:
      return state;
  }
}
